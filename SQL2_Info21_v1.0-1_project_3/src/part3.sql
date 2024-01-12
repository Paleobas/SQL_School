-- 1) Write a function that returns the TransferredPoints table in a more human-readable form
-- Peer's nickname 1, Peer's nickname 2, number of transferred peer points.
-- The number is negative if peer 2 received more points from peer 1.

CREATE OR REPLACE FUNCTION fnc_transferred_points()
RETURNS TABLE(peer_1 VARCHAR, peer_2 VARCHAR, points_amount INTEGER) AS
$transferred_points$
BEGIN
    RETURN QUERY
    WITH tmp AS (
        SELECT  tp1.id AS id1, tp2.id AS id2,
            tp1.checking_peer AS checking_1, tp2.checking_peer AS checking_2,
            tp1.checked_peer AS checked_1, tp2.checked_peer AS checked_2,
            tp1.points_amount AS points_amount_1, tp2.points_amount AS points_amount_2
        FROM TransferredPoints tp1
            LEFT OUTER JOIN TransferredPoints tp2
            ON tp1.checked_peer = tp2.checking_peer
                AND tp1.checking_peer = tp2.checked_peer
    )
    SELECT checking_1, checked_1,
        (COALESCE(points_amount_1, 0) - COALESCE(points_amount_2, 0))
    FROM tmp
    WHERE id1 < id2 OR id2 IS NULL;
END;
$transferred_points$
LANGUAGE plpgsql;

-- SELECT * FROM fnc_transferred_points();

-- ==================================================================================================================================================

-- 2) Write a function that returns a table of the following form: user name, name of the checked task, number of XP received
-- Include in the table only tasks that have successfully passed the check (according to the Checks table).
-- One task can be completed successfully several times. In this case, include all successful checks in the table.

CREATE OR REPLACE FUNCTION fnc_successful_checks()
RETURNS TABLE(peer VARCHAR, task VARCHAR, xp INTEGER) AS
$successful_checks$
BEGIN
    RETURN QUERY
    SELECT DISTINCT P2P.checking_peer, Checks.task, XP.xp_amount
    FROM P2P
        JOIN Checks
        ON Checks.id = P2P.check_id
        JOIN XP
        ON P2P.check_id = XP.check_id
    ORDER BY 1, 2, 3;
END;
$successful_checks$
LANGUAGE plpgsql;

-- SELECT * FROM fnc_successful_checks();

-- ==================================================================================================================================================

-- 3) Write a function that finds the peers who have not left campus for the whole day
-- Function parameters: day, for example 12.05.2023.
-- The function returns only a list of peers.

CREATE OR REPLACE FUNCTION fnc_peers_in_campus(checking_date DATE)
RETURNS TABLE(peers VARCHAR) AS
$peers_in_campus$
BEGIN
    RETURN QUERY
    SELECT peer
    FROM (
        SELECT peer, COUNT(*) AS count
        FROM TimeTracking
        WHERE date = checking_date AND state = 2
        GROUP BY peer
        ) AS temp
    WHERE count = 1;
END;
$peers_in_campus$
LANGUAGE plpgsql;

-- SELECT * FROM fnc_peers_in_campus('2023-11-28');

-- ==================================================================================================================================================

-- 4) Calculate the change in the number of peer points of each peer using the TransferredPoints table
-- Output the result sorted by the change in the number of points.
-- Output format: peer's nickname, change in the number of peer points

CREATE OR REPLACE PROCEDURE prc_change_points(IN result REFCURSOR) AS
$change_points$
BEGIN
    OPEN result FOR
    SELECT checking_peer AS peer,
        SUM(points_amount) AS points_change
    FROM (
        SELECT checking_peer,
            SUM(points_amount) AS points_amount
        FROM TransferredPoints
        GROUP BY checking_peer
        UNION ALL
        SELECT checked_peer,
            SUM(-points_amount) AS points_amount
        FROM TransferredPoints
        GROUP BY checked_peer
        ) AS change_points
    GROUP BY checking_peer
    ORDER BY points_change DESC;
END;
$change_points$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_change_points('result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 5) Calculate the change in the number of peer points of each peer using the table returned by the first function from Part 3
-- Output the result sorted by the change in the number of points.
-- Output format: peer's nickname, change in the number of peer points

CREATE OR REPLACE PROCEDURE prc_change_points_from_fnc(IN result REFCURSOR) AS
$change_points_from_fnc$
BEGIN
    OPEN result FOR
    SELECT peer_1 AS peer,
        SUM(points_amount) AS points_change
    FROM (
        SELECT peer_1,
            SUM(points_amount) AS points_amount
        FROM fnc_transferred_points()
        GROUP BY peer_1
        UNION ALL
        SELECT peer_2,
            SUM(-points_amount) AS points_amount
        FROM fnc_transferred_points()
        GROUP BY peer_2
        ) AS change_points
    GROUP BY peer
    ORDER BY points_change DESC;
END;
$change_points_from_fnc$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_change_points_from_fnc('result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 6) Find the most frequently checked task for each day
-- If there is the same number of checks for some tasks in a certain day, output all of them.
-- Output format: day, task name

CREATE OR REPLACE PROCEDURE prc_freq_checked_task(IN result REFCURSOR) AS
$freq_checked_task$
BEGIN
    OPEN result FOR
    WITH tmp AS (
        SELECT date, task,
            COUNT(date) AS count
        FROM Checks
        GROUP BY date, task
        ORDER BY date
    )
    SELECT t1.date AS Day, t1.task
    FROM tmp t1
        LEFT JOIN tmp t2
        ON t2.task != t1.task AND t2.date = t1.date
            AND t2.count < t1.count
    WHERE t2.date IS NULL;
END;
$freq_checked_task$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_freq_checked_task('result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 7) Find all peers who have completed the whole given block of tasks and the completion date of the last task
-- Procedure parameters: name of the block, for example “CPP”.
-- The result is sorted by the date of completion.
-- Output format: peer's name, date of completion of the block (i.e. the last completed task from that block)

CREATE OR REPLACE PROCEDURE prc_peers_completed_tasks_block(IN result REFCURSOR, IN block_name VARCHAR) AS
$peers_completed_tasks_block$
BEGIN
    OPEN result FOR
    WITH tmp AS (
        SELECT * FROM Tasks
        WHERE title_name SIMILAR TO CONCAT(block_name, '[0-9]%')),
            check_name AS (SELECT MAX(title_name) AS title FROM tmp),
            check_date AS (
                SELECT peer, task, date
                FROM Checks c
                    JOIN P2P
                    ON c.id = P2P.check_id
                WHERE P2P.state = 'success'
            )
    SELECT cd.peer AS peer,
        to_char(date, 'dd.mm.yyyy') AS day
    FROM check_date cd
        JOIN check_name cn
        ON cd.task = cn.title;
END;
$peers_completed_tasks_block$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_peers_completed_tasks_block('result', 'CPP');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 8) Determine which peer each student should go to for a check.
-- You should determine it according to the recommendations of the peer's friends,
-- i.e. you need to find the peer with the greatest number of friends who recommend to be checked by him.
-- Output format: peer's nickname, nickname of the checker found

CREATE OR REPLACE PROCEDURE prc_peers_for_checks(IN result REFCURSOR) AS
$peers_for_checks$
BEGIN
    OPEN result FOR
    WITH friends_rec AS (
        SELECT peer1, peer2 AS friend
        FROM Friends
        UNION ALL
        SELECT peer2, peer1 AS friend
        FROM Friends
        ), recs AS (
        SELECT DISTINCT ON(peer1) peer1, recommended_peer,
        COUNT(friend) AS count
        FROM friends_rec fr
            FULL JOIN recommendations r
            ON fr.friend = r.peer
        WHERE peer1 != recommended_peer
        GROUP BY peer1, recommended_peer
        ORDER BY peer1, count DESC
        )
    SELECT peer1, recommended_peer
    FROM recs;
END;
$peers_for_checks$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_peers_for_checks('result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 9) Determine the percentage of peers who:
-- Started only block 1
-- Started only block 2
-- Started both
-- Have not started any of them
-- A peer is considered to have started a block if he has at least one check of any task from this block (according to the Checks table)
-- Procedure parameters: name of block 1, for example SQL, name of block 2, for example A.
-- Output format: percentage of those who started only the first block, percentage of those who started only the second block,
-- percentage of those who started both blocks, percentage of those who did not started any of them

CREATE OR REPLACE PROCEDURE prc_started_blocks(first_block VARCHAR, second_block VARCHAR, IN result REFCURSOR) AS
$started_blocks$
BEGIN
    OPEN result FOR
    WITH block_1 AS (
        SELECT DISTINCT peer
        FROM Checks
        WHERE task SIMILAR TO CONCAT(first_block, '[0-9]%')
        ), block_2 AS (
        SELECT DISTINCT peer
        FROM Checks
        WHERE task SIMILAR TO CONCAT(second_block, '[0-9]%')
        ), blocks AS (
        SELECT DISTINCT peer
        FROM block_1
        INTERSECT
        SELECT DISTINCT peer
        FROM block_2
        ), without_blocks AS (
        SELECT nickname AS peer
        FROM Peers
        EXCEPT
        (SELECT DISTINCT peer FROM block_1
        UNION
        SELECT DISTINCT peer FROM block_2)
        )
    SELECT (SELECT COUNT(peer) FROM block_1) / (COUNT(nickname) * 0.01) AS StartedBlock1,
        (SELECT COUNT(peer) FROM block_2) / (COUNT(nickname) * 0.01) AS StartedBlock2,
        (SELECT COUNT(peer) FROM blocks) / (COUNT(nickname) * 0.01) AS StartedBothBlocks,
        (SELECT COUNT(peer) FROM without_blocks) / (COUNT(nickname) * 0.01) AS DidntStartAnyBlock
    FROM Peers;
END;
$started_blocks$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_started_blocks('CPP', 'A', 'result');
-- FETCH ALL IN "result";
-- END;

-- INSERT INTO Tasks VALUES ('C_3DViewer_v1.0', NULL, 750);
-- INSERT INTO Tasks VALUES ('SQL1', 'C_3DViewer_v1.0', 1500);
-- INSERT INTO Tasks VALUES ('SQL2_Info21 v1.0', 'SQL1', 500);
-- INSERT INTO Checks (peer, task, date) VALUES ('Alex Muss', 'C_3DViewer_v1.0', '2023-10-16');
-- INSERT INTO Checks (peer, task, date) VALUES ('Harry Potter', 'C_3DViewer_v1.0', '2023-10-21');
-- INSERT INTO Checks (peer, task, date) VALUES ('Harry Potter', 'SQL1', '2023-11-23');

-- BEGIN;
-- CALL prc_started_blocks('SQL', 'C', 'result');
-- FETCH ALL IN "result";
-- END;

-- ==================================================================================================================================================

-- 10) Determine the percentage of peers who have ever successfully passed a check on their birthday
-- Also determine the percentage of peers who have ever failed a check on their birthday.
-- Output format: percentage of peers who have ever successfully passed a check on their birthday,
-- percentage of peers who have ever failed a check on their birthday

CREATE OR REPLACE PROCEDURE prc_birthday_checks(IN result REFCURSOR) AS
$birthday_checks$
BEGIN
    OPEN result FOR
    SELECT (
        SELECT COUNT(*) * 100 / (SELECT COUNT(*) FROM Peers)
        FROM (
            SELECT DISTINCT nickname
            FROM Peers
                JOIN Checks
                ON nickname = peer
                    AND EXTRACT(MONTH FROM birthday) = EXTRACT(MONTH FROM "date")
                    AND EXTRACT(DAY FROM birthday) = EXTRACT(DAY FROM "date")
                JOIN P2P
                ON checks.id = P2P.check_id
            WHERE P2P.state = 'success'
        ) AS temp1
    ) AS SuccessfulChecks, (
    SELECT COUNT(*) * 100/ (SELECT COUNT(*) FROM peers)
    FROM (
        SELECT DISTINCT nickname
        FROM Peers
            JOIN Checks
            ON nickname = peer
                AND EXTRACT(MONTH FROM birthday) = EXTRACT(MONTH FROM "date")
                AND EXTRACT(DAY FROM birthday) = EXTRACT(DAY FROM "date")
            JOIN P2P
            ON checks.id = P2P.check_id
        WHERE P2P.state = 'failure'
        ) AS temp2
    ) AS UnsuccessfulChecks;
END;
$birthday_checks$
LANGUAGE plpgsql;

-- INSERT INTO Checks (peer, task, date) VALUES ('Harry Potter', 'C_3DViewer_v1.0', '2023-07-31');
-- INSERT INTO Verter (check_id, state, time) VALUES (15, 'start', '11:48');
-- INSERT INTO Verter (check_id, state, time) VALUES (15, 'success', '12:09');
-- INSERT INTO Checks (peer, task, date) VALUES ('Alex Muss', 'C_3DViewer_v1.0', '2022-12-15');
-- INSERT INTO Verter (check_id, state, time) VALUES (16, 'start', '11:48');
-- INSERT INTO Verter (check_id, state, time) VALUES (16, 'success', '12:09');

-- BEGIN;
-- CALL prc_birthday_checks('result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 11) Determine all peers who did the given tasks 1 and 2, but did not do task 3
-- Procedure parameters: names of tasks 1, 2 and 3.
-- Output format: list of peers

CREATE OR REPLACE PROCEDURE prc_peers_passed_tasks_1_2(t1 VARCHAR, t2 VARCHAR, t3 VARCHAR, IN result REFCURSOR) AS
$peers_passed_tasks_1_2$
BEGIN
    OPEN result FOR
    WITH success_task AS (
        SELECT peer, task, xp_amount
        FROM Checks
            JOIN P2P
            ON checks.id = P2P.check_id
            JOIN XP
            ON checks.id = XP.check_id
        WHERE state = 'success'
        ORDER BY peer
        ), task1 AS (
        SELECT peer FROM success_task WHERE success_task.task LIKE t1
        ), task2 AS (
        SELECT peer FROM success_task WHERE success_task.task LIKE t2
        ), task3 AS (
        SELECT peer FROM success_task WHERE success_task.task NOT LIKE t3
    )
    SELECT *
    FROM (
        (SELECT * FROM task1)
        INTERSECT
        (SELECT * FROM task2)
        INTERSECT
        (SELECT * FROM task3)
    ) AS temp;
END;
$peers_passed_tasks_1_2$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_peers_passed_tasks_1_2('C2_SimpleBashUtils', 'C3_s21_string+', 'CPP2_s21_containers', 'result');
-- FETCH ALL IN result;
-- END;

-- BEGIN;
-- CALL prc_peers_passed_tasks_1_2('CPP2_s21_containers', 'A1_Maze', 'A2_SimpleNavigator_v1.0', 'result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 12) Using recursive common table expression, output the number of preceding tasks for each task
-- I. e. How many tasks have to be done, based on entry conditions, to get access to the current one.
-- Output format: task name, number of preceding tasks

CREATE OR REPLACE PROCEDURE prc_preceding_tasks(task VARCHAR, IN result REFCURSOR) AS
$preceding_tasks$
BEGIN
    OPEN result FOR
    WITH RECURSIVE r AS (
        SELECT (
            CASE
                WHEN (tasks.parent_task IS NULL)
                THEN 0
                ELSE 1
            END
        ) AS counter,
        tasks.title_name,
        tasks.parent_task AS current_tasks,
        tasks.parent_task
        FROM Tasks
        UNION ALL
        SELECT (
            CASE
                WHEN child.parent_task IS NOT NULL
                THEN counter + 1
                ELSE counter
            END
        ) AS counter,
        child.title_name AS title,
        child.parent_task AS current_tasks,
        parrent.title_name AS parrenttask
        FROM Tasks AS child
            CROSS JOIN r AS parrent
        WHERE parrent.title_name LIKE child.parent_task
    )
    SELECT split_part(title_name, '_', 1) AS Task,
        MAX(counter) AS PrevCount
    FROM r
    WHERE title_name LIKE CONCAT(task, '%')
    GROUP BY title_name
    ORDER BY 1;
END;
$preceding_tasks$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_preceding_tasks('CPP3', 'result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 13) Find "lucky" days for checks. A day is considered "lucky" if it has at least N consecutive successful checks
-- Parameters of the procedure: the N number of consecutive successful checks .
-- The time of the check is the start time of the P2P step.
-- Successful consecutive checks are the checks with no unsuccessful checks in between.
-- The amount of XP for each of these checks must be at least 80% of the maximum.
-- Output format: list of days

CREATE OR REPLACE PROCEDURE prc_lucky_days_for_checks(n INTEGER, IN result REFCURSOR) AS
$lucky_days_for_checks$
BEGIN
    OPEN result FOR
    WITH tmp AS (
        SELECT c.id, date, peer, v.check_id, v.state
        FROM Checks c
            JOIN P2P
            ON c.id = P2P.check_id AND (P2P.state = 'success')
            JOIN verter v
            ON c.id = v.check_id AND (v.state = 'success')
        ORDER BY date
    )
    SELECT date FROM tmp
    GROUP BY date
    HAVING COUNT(date) >= n;
END;
$lucky_days_for_checks$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_lucky_days_for_checks(2, 'result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 14) Find the peer with the highest amount of XP
-- Output format: peer's nickname, amount of XP

CREATE OR REPLACE PROCEDURE prc_highest_xp(IN result REFCURSOR) AS
$highest_xp$
BEGIN
    OPEN result FOR
    WITH xp_count AS (
        SELECT peer, SUM(xp_amount) AS xp
        FROM Checks c
            JOIN P2P
            ON c.id = P2P.check_id
            JOIN XP
            ON c.id = XP.check_id
        WHERE state = 'success'
        GROUP BY peer
        ORDER BY xp DESC)
    SELECT peer
    FROM xp_count
    WHERE xp = (SELECT MAX(xp) FROM xp_count)
    GROUP BY peer;
END;
$highest_xp$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_highest_xp('result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 15) Determine the peers that came before the given time at least N times during the whole time
-- Procedure parameters: time, N number of times .
-- Output format: list of peers

CREATE OR REPLACE PROCEDURE prc_came_before_the_time(fix_time TIME, n INTEGER, IN result REFCURSOR) AS
$came_before_the_time$
BEGIN
    OPEN result FOR
    SELECT peer
    FROM TimeTracking
    WHERE (state = 1) AND (timetracking.time < fix_time)
    GROUP BY peer
    HAVING COUNT(peer) > n;
END;
$came_before_the_time$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_came_before_the_time('21:20:00', 1, 'result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 16) Determine the peers who left the campus more than M times during the last N days
-- Procedure parameters: N number of days , M number of times .
-- Output format: list of peers

CREATE OR REPLACE PROCEDURE prc_left_campus(n INTEGER, m INTEGER, IN result REFCURSOR) AS
$left_campus$
BEGIN
    OPEN result FOR
    WITH tmp AS (
        SELECT peer, date,
            COUNT(*) AS count
        FROM TimeTracking
        WHERE (state = 2) AND (date > (SELECT now()::DATE - n))
        GROUP BY peer, date
        ORDER BY date
    )
    SELECT Peer FROM tmp
    GROUP BY peer
    HAVING SUM(count) > m;
END;
$left_campus$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_left_campus(200, 1, 'result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================

-- 17) Determine for each month the percentage of early entries
-- For each month, count how many times people born in that month came to campus during the whole time (we'll call this the total number of entries).
-- For each month, count the number of times people born in that month have come to campus before 12:00 in all time (we'll call this the number of early entries).
-- For each month, count the percentage of early entries to campus relative to the total number of entries.
-- Output format: month, percentage of early entries

CREATE OR REPLACE PROCEDURE prc_early_entries(IN result REFCURSOR) AS
$early_entries$
BEGIN
    OPEN result FOR
    WITH birthdays AS (
        SELECT birthday::DATE, nickname,
            date_part('month', birthday)::NUMERIC AS date_month, COUNT(date) AS date_count
        FROM Peers
            JOIN TimeTracking
            ON peers.nickname = timetracking.peer
        WHERE state = 1 AND time < '12:00:00'
        GROUP BY nickname, date_part('month', birthday)::NUMERIC
        ORDER BY date_month
        ), months AS (
        SELECT date_part('month', GENERATE_SERIES('2023-01-01', '2023-12-31', interval '1 month')::DATE) AS id,
            to_char(GENERATE_SERIES('2023-01-01', '2023-12-31', interval '1 month')::DATE, 'Month') AS num,
            birthday, date_part('month', birthday)::NUMERIC AS date_month
        FROM Peers
        ), all_times AS (
        SELECT DISTINCT m.birthday, num, id, SUM(date_count) AS sum_count
        FROM months m
            JOIN birthdays bd
            ON bd.date_month = m.date_month
        WHERE id = m.date_month
        GROUP BY m.birthday, num, id
        ORDER BY id
        )
    SELECT num AS Month, ROUND(EarlyEntries * 100 / (SELECT COUNT(date) FROM TimeTracking WHERE state = 1))
    FROM (SELECT id, num, SUM(sum_count) AS EarlyEntries FROM all_times GROUP BY id, num) AS foo;
END;
$early_entries$
LANGUAGE plpgsql;

-- BEGIN;
-- CALL prc_early_entries('result');
-- FETCH ALL IN result;
-- END;

-- ==================================================================================================================================================
