-- 1) Write a procedure for adding P2P check
-- Parameters: nickname of the person being checked, checker's nickname, task name, P2P check status, time.
-- If the status is "start", add a record in the Checks table (use today's date).
-- Add a record in the P2P table.
-- If the status is "start", specify the record just added as a check, otherwise specify the check with the unfinished P2P step.

CREATE OR REPLACE PROCEDURE prc_add_p2p_check(
    IN checked CHARACTER VARYING,
    IN checking CHARACTER VARYING,
    IN task_name CHARACTER VARYING,
    IN state CHECK_STATUS,
    IN p2p_time TIME WITHOUT TIME ZONE
) AS
$add_p2p_check$
DECLARE
    id_check INTEGER := 0;
BEGIN
    IF state = 'start'
    THEN
        id_check = (SELECT MAX(id) FROM Checks) + 1;
            INSERT INTO Checks(id, peer, task, date)
            VALUES (id_check, checked, task_name, (SELECT current_date));
    ELSE
        id_check = (
            SELECT Checks.id
            FROM P2P
                JOIN Checks
                ON Checks.id = P2P.check_id
            WHERE checking_peer = checking
                AND peer = checked AND task = task_name
            ORDER BY Checks.id DESC
            LIMIT 1
        );
    END IF;
    INSERT INTO P2P(check_id, checking_peer, state, time)
    VALUES (id_check, checking, state, p2p_time);
END;
$add_p2p_check$
LANGUAGE plpgsql;

-- CALL prc_add_p2p_check('Ginevra Weasley', 'Alex Muss', 'CPP1_s21_matrix+', 'start', '09:00:00');
-- CALL prc_add_p2p_check('Ginevra Weasley', 'Alex Muss', 'CPP1_s21_matrix+', 'success', '09:20:00');

-- ==================================================================================================================================================

-- 2) Write a procedure for adding checking by Verter
-- Parameters: nickname of the person being checked, task name, Verter check status, time.
-- Add a record to the Verter table (as a check specify the check of the corresponding task with the latest (by time) successful P2P step)

CREATE OR REPLACE PROCEDURE prc_add_verter_check(
    IN nickname CHARACTER VARYING,
    IN task_name CHARACTER VARYING,
    IN verter_state CHECK_STATUS,
    IN check_time TIME WITHOUT TIME ZONE
) AS
$add_verter_check$
DECLARE
    id_check INTEGER := (
        SELECT Checks.id
        FROM P2P
            JOIN Checks
            ON Checks.id = P2P.check_id AND P2P.state = 'success'
                AND Checks.task = task_name AND Checks.peer = nickname
        ORDER BY P2P.time
        LIMIT 1
    );
BEGIN
    INSERT INTO Verter(check_id, state, time)
    VALUES (id_check, verter_state, check_time);
END;
$add_verter_check$
LANGUAGE plpgsql;

-- CALL prc_add_verter_check('Ginevra Weasley','CPP1_s21_matrix+','start','09:21:00');
-- CALL prc_add_verter_check('Ginevra Weasley', 'CPP1_s21_matrix+', 'success', '09:22:00');

-- ==================================================================================================================================================

-- 3) Write a trigger: after adding a record with the "start" status to the P2P table, change the corresponding record in the TransferredPoints table

CREATE OR REPLACE FUNCTION fnc_update_transferred_points()
RETURNS TRIGGER AS
$update_transferred_points$
BEGIN
    IF (NEW.state = 'start')
    THEN
        INSERT INTO TransferredPoints VALUES(
            (SELECT COALESCE((MAX(id) + 1), 1) FROM TransferredPoints),
            NEW.checking_peer,
            (SELECT peer FROM Checks WHERE id = NEW.check_id),
            1
        );
    END IF;
    RETURN NEW;
END;
$update_transferred_points$
LANGUAGE plpgsql;

CREATE TRIGGER trg_update_table_transferred_points
    AFTER INSERT
    ON P2P
    FOR EACH ROW
EXECUTE FUNCTION fnc_update_transferred_points();

-- CALL prc_add_p2p_check('Ronald Weasley', 'Harry Potter', 'CPP1_s21_matrix+', 'start', '10:00:00');
-- CALL prc_add_p2p_check('Ronald Weasley', 'Harry Potter', 'CPP1_s21_matrix+', 'success', '10:20:00');
-- SELECT * FROM TransferredPoints;

-- ==================================================================================================================================================

-- 4) Write a trigger: before adding a record to the XP table, check if it is correct
-- The record is considered correct if:
--   The number of XP does not exceed the maximum available for the task being checked
--   The Check field refers to a successful check
--   If the record does not pass the check, do not add it to the table.

CREATE OR REPLACE FUNCTION fnc_check_correctness_record()
RETURNS TRIGGER AS
$check_correctness_record$
DECLARE
    status VARCHAR(20);
    max_xp INTEGER;
BEGIN
    SELECT Tasks.max_xp INTO max_xp
    FROM Checks
        JOIN Tasks
        ON Tasks.title_name = Checks.task;

    SELECT P2P.state INTO status
    FROM Checks
        JOIN P2P
        ON Checks.id = P2P.check_id;

    IF NEW.xp_amount > max_xp
    THEN
        RAISE EXCEPTION 'The number of XP exceed the maximum available for the task';
    ELSEIF status = 'failure'
    THEN
        RAISE EXCEPTION 'The record does not pass the check';
    ELSE
        RETURN NEW;
    END IF;
END;
$check_correctness_record$
LANGUAGE plpgsql;

CREATE TRIGGER trg_update_xp
    BEFORE INSERT
    ON XP
    FOR EACH ROW
EXECUTE FUNCTION fnc_check_correctness_record();

-- INSERT INTO XP (check_id, xp_amount) VALUES (12, 1000);
-- INSERT INTO XP (check_id, xp_amount) VALUES (12, 200);

-- ==================================================================================================================================================
