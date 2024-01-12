-- DROP DATABASE info_21;

-- CREATE DATABASE info_21;

-- DROP SCHEMA IF EXISTS public CASCADE;

-- DROP TABLE IF EXISTS Tasks, P2P, Verter, Checks, XP, Peers,
--     TransferredPoints, Friends, Recommendations, TimeTracking CASCADE;

CREATE TABLE IF NOT EXISTS Peers (
    nickname VARCHAR PRIMARY KEY,
    birthday DATE NOT NULL
);

--DROP TABLE Peers;

INSERT INTO Peers VALUES ('Alex Muss', '2001-12-15');
INSERT INTO Peers VALUES ('Harry Potter', '2000-07-31');
INSERT INTO Peers VALUES ('Hermione Granger', '1999-09-19');
INSERT INTO Peers VALUES ('Ronald Weasley', '2000-03-01');
INSERT INTO Peers VALUES ('Ginevra Weasley', '2001-02-12');
INSERT INTO Peers VALUES ('Draco Malfoy', '2000-06-05');
INSERT INTO Peers VALUES ('Vincent Crabbe', '1999-07-01');
INSERT INTO Peers VALUES ('Pansy Parkinson', '2000-01-19');

CREATE TABLE IF NOT EXISTS Tasks (
    title_name  VARCHAR NOT NULL PRIMARY KEY,
    parent_task VARCHAR NULL REFERENCES Tasks(title_name),
    max_xp INTEGER NOT NULL
);

--DROP TABLE Tasks;

INSERT INTO Tasks VALUES ('CPP1_s21_matrix+', NULL, 300);
INSERT INTO Tasks VALUES ('CPP2_s21_containers', 'CPP1_s21_matrix+', 350);
INSERT INTO Tasks VALUES ('CPP3_SmartCalc_v2.0', 'CPP2_s21_containers', 600);
INSERT INTO Tasks VALUES ('A1_Maze', 'CPP3_SmartCalc_v2.0', 300);
INSERT INTO Tasks VALUES ('A2_SimpleNavigator_v1.0', 'A1_Maze', 400);
INSERT INTO Tasks VALUES ('A3_Parallels', 'A2_SimpleNavigator_v1.0', 300);

CREATE TABLE IF NOT EXISTS Checks (
    id BIGSERIAL PRIMARY KEY,
    peer VARCHAR NOT NULL REFERENCES Peers(nickname),
    task VARCHAR NOT NULL REFERENCES Tasks(title_name),
    Date DATE NOT NULL
);

--DROP TABLE Checks;

INSERT INTO Checks(peer, task, date) VALUES ('Alex Muss', 'CPP1_s21_matrix+', '2023-10-16');
INSERT INTO Checks(peer, task, date) VALUES ('Harry Potter', 'CPP2_s21_containers', '2023-10-16');
INSERT INTO Checks(peer, task, date) VALUES ('Hermione Granger', 'CPP2_s21_containers', '2023-10-16');
INSERT INTO Checks(peer, task, date) VALUES ('Hermione Granger', 'A1_Maze', '2023-10-17');
INSERT INTO Checks(peer, task, date) VALUES ('Ronald Weasley', 'CPP3_SmartCalc_v2.0', '2023-10-17');
INSERT INTO Checks(peer, task, date) VALUES ('Ginevra Weasley', 'CPP3_SmartCalc_v2.0', '2023-10-17');
INSERT INTO Checks(peer, task, date) VALUES ('Ginevra Weasley', 'CPP1_s21_matrix+', '2023-10-16');
INSERT INTO Checks(peer, task, date) VALUES ('Draco Malfoy', 'CPP2_s21_containers', '2023-10-24');
INSERT INTO Checks(peer, task, date) VALUES ('Draco Malfoy', 'A1_Maze', '2023-11-12');
INSERT INTO Checks(peer, task, date) VALUES ('Ginevra Weasley', 'A1_Maze', '2023-11-14');
INSERT INTO Checks(peer, task, date) VALUES ('Vincent Crabbe', 'A2_SimpleNavigator_v1.0', '2023-11-16');

CREATE TYPE CHECK_STATUS AS
ENUM('start', 'success', 'failure');

-- DROP TYPE CHECK_STATUS CASCADE;

CREATE TABLE IF NOT EXISTS P2P (
    id BIGSERIAL PRIMARY KEY,
    check_id BIGINT REFERENCES Checks(id),
    checking_peer VARCHAR NOT NULL REFERENCES Peers(nickname),
    state CHECK_STATUS NOT NULL,
    time TIME NOT NULL,
    UNIQUE(check_id, checking_peer, state)
);

-- DROP TABLE P2P;

INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (1, 'Alex Muss', 'start', '20:30');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (1, 'Alex Muss', 'success', '21:04');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (2, 'Harry Potter', 'start', '13:03');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (2, 'Harry Potter', 'success', '13:37');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (3, 'Hermione Granger', 'start', '08:17');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (3, 'Hermione Granger', 'success', '09:03');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (4, 'Alex Muss', 'start', '00:00');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (4, 'Alex Muss', 'success', '00:44');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (5, 'Ginevra Weasley', 'start', '17:01');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (5, 'Ginevra Weasley', 'success', '17:48');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (6, 'Ginevra Weasley', 'start', '11:32');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (6, 'Ginevra Weasley', 'success', '12:13');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (7, 'Draco Malfoy', 'start', '21:00:29');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (7, 'Draco Malfoy', 'success', '21:31:57');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (9, 'Alex Muss', 'start', '08:30');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (9, 'Alex Muss', 'success', '09:12');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (10, 'Hermione Granger', 'start', '18:30');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (10, 'Hermione Granger', 'failure', '19:12');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (11, 'Hermione Granger', 'start', '10:12');
INSERT INTO P2P(check_id, checking_peer, state, time) VALUES (11, 'Hermione Granger', 'success', '11:02');

CREATE TABLE IF NOT EXISTS Verter (
    id BIGSERIAL PRIMARY KEY,
    check_id BIGINT REFERENCES Checks(id),
    state CHECK_STATUS NOT NULL,
    time TIME NOT NULL,
    UNIQUE(check_id, state)
);

--DROP TABLE Verter;

INSERT INTO Verter(check_id, state, time) VALUES (1, 'start', '21:05');
INSERT INTO Verter(check_id, state, time) VALUES (1, 'success', '21:07');
INSERT INTO Verter(check_id, state, time) VALUES (2, 'start', '13:37');
INSERT INTO Verter(check_id, state, time) VALUES (2, 'success', '13:38');
INSERT INTO Verter(check_id, state, time) VALUES (3, 'start', '09:03');
INSERT INTO Verter(check_id, state, time) VALUES (3, 'success', '09:04');
INSERT INTO Verter(check_id, state, time) VALUES (4, 'start', '00:44');
INSERT INTO Verter(check_id, state, time) VALUES (4, 'success', '00:45');
INSERT INTO Verter(check_id, state, time) VALUES (5, 'start', '17:48');
INSERT INTO Verter(check_id, state, time) VALUES (5, 'success', '17:49');
INSERT INTO Verter(check_id, state, time) VALUES (7, 'start', '06:57');
INSERT INTO Verter(check_id, state, time) VALUES (7, 'success', '06:58');
INSERT INTO Verter(check_id, state, time) VALUES (8, 'start', '07:47');
INSERT INTO Verter(check_id, state, time) VALUES (8, 'success', '07:49');
INSERT INTO Verter(check_id, state, time) VALUES (9, 'start', '17:48');
INSERT INTO Verter(check_id, state, time) VALUES (9, 'failure', '17:49');
INSERT INTO Verter(check_id, state, time) VALUES (11, 'start', '11:48');
INSERT INTO Verter(check_id, state, time) VALUES (11, 'success', '12:09');

CREATE TABLE IF NOT EXISTS XP (
    id BIGSERIAL PRIMARY KEY,
    check_id  BIGINT REFERENCES Checks(id) UNIQUE,
    xp_amount INTEGER NOT NULL CHECK(xp_amount > 0)
);

--DROP TABLE XP;

INSERT INTO XP(check_id, xp_amount) VALUES (1, 280);
INSERT INTO XP(check_id, xp_amount) VALUES (2, 350);
INSERT INTO XP(check_id, xp_amount) VALUES (3, 350);
INSERT INTO XP(check_id, xp_amount) VALUES (4, 300);
INSERT INTO XP(check_id, xp_amount) VALUES (5, 550);
INSERT INTO XP(check_id, xp_amount) VALUES (6, 600);
INSERT INTO XP(check_id, xp_amount) VALUES (7, 300);
INSERT INTO XP(check_id, xp_amount) VALUES (11, 400);

CREATE TABLE IF NOT EXISTS TransferredPoints (
    id BIGSERIAL PRIMARY KEY,
    checking_peer  VARCHAR NOT NULL REFERENCES Peers(nickname),
    checked_peer  VARCHAR NOT NULL REFERENCES Peers(nickname),
    points_amount INTEGER NOT NULL CHECK(points_amount > 0),
    UNIQUE(checking_peer, checked_peer)
);

-- DROP TABLE TransferredPoints;

INSERT INTO TransferredPoints(checking_peer, checked_peer, points_amount) VALUES ('Alex Muss', 'Harry Potter', 1);
INSERT INTO TransferredPoints(checking_peer, checked_peer, points_amount) VALUES ('Harry Potter', 'Alex Muss', 5);
INSERT INTO TransferredPoints(checking_peer, checked_peer, points_amount) VALUES ('Hermione Granger', 'Alex Muss', 3);
INSERT INTO TransferredPoints(checking_peer, checked_peer, points_amount) VALUES ('Ginevra Weasley', 'Hermione Granger', 7);
INSERT INTO TransferredPoints(checking_peer, checked_peer, points_amount) VALUES ('Draco Malfoy', 'Vincent Crabbe', 2);
INSERT INTO TransferredPoints(checking_peer, checked_peer, points_amount) VALUES ('Vincent Crabbe', 'Draco Malfoy', 4);
INSERT INTO TransferredPoints(checking_peer, checked_peer, points_amount) VALUES ('Hermione Granger', 'Vincent Crabbe', 3);
INSERT INTO TransferredPoints(checking_peer, checked_peer, points_amount) VALUES ('Harry Potter', 'Draco Malfoy', 1);

CREATE TABLE IF NOT EXISTS Friends (
    id BIGSERIAL PRIMARY KEY,
    peer1 VARCHAR NOT NULL REFERENCES Peers(nickname),
    peer2 VARCHAR NOT NULL REFERENCES Peers(nickname),
    UNIQUE(peer1, peer2)
);

-- DROP TABLE Friends;

INSERT INTO Friends(peer1, peer2) VALUES ('Alex Muss', 'Ginevra Weasley');
INSERT INTO Friends(peer1, peer2) VALUES ('Alex Muss', 'Draco Malfoy');
INSERT INTO Friends(peer1, peer2) VALUES ('Harry Potter', 'Ginevra Weasley');
INSERT INTO Friends(peer1, peer2) VALUES ('Draco Malfoy', 'Ginevra Weasley');
INSERT INTO Friends(peer1, peer2) VALUES ('Harry Potter', 'Draco Malfoy');
INSERT INTO Friends(peer1, peer2) VALUES ('Alex Muss', 'Harry Potter');
INSERT INTO Friends(peer1, peer2) VALUES ('Harry Potter', 'Hermione Granger');
INSERT INTO Friends(peer1, peer2) VALUES ('Alex Muss', 'Hermione Granger');

CREATE TABLE IF NOT EXISTS Recommendations (
    id BIGSERIAL PRIMARY KEY,
    peer VARCHAR NOT NULL REFERENCES Peers(nickname),
    recommended_peer VARCHAR NOT NULL REFERENCES Peers(nickname) CHECK(recommended_peer <> peer),
    UNIQUE(peer, recommended_peer)
);

-- DROP TABLE Recommendations;

INSERT INTO Recommendations(peer, recommended_peer) VALUES ('Alex Muss', 'Ginevra Weasley');
INSERT INTO Recommendations(peer, recommended_peer) VALUES ('Harry Potter', 'Hermione Granger');
INSERT INTO Recommendations(peer, recommended_peer) VALUES ('Draco Malfoy', 'Hermione Granger');
INSERT INTO Recommendations(peer, recommended_peer) VALUES ('Hermione Granger', 'Vincent Crabbe');
INSERT INTO Recommendations(peer, recommended_peer) VALUES ('Vincent Crabbe', 'Ginevra Weasley');
INSERT INTO Recommendations(peer, recommended_peer) VALUES ('Vincent Crabbe', 'Hermione Granger');

CREATE TABLE IF NOT EXISTS TimeTracking (
    id BIGSERIAL PRIMARY KEY,
    peer VARCHAR NOT NULL REFERENCES Peers(nickname),
    date DATE NOT NULL,
    time TIME NOT NULL,
    state INTEGER NOT NULL CHECK(state IN (1, 2)),
    UNIQUE(peer, date, time)
);

-- DROP TABLE TimeTracking;

INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Vincent Crabbe', '2023-11-01', '15:00', 1);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Vincent Crabbe', '2023-11-01', '18:43', 2);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Vincent Crabbe', '2023-11-01', '19:50', 1);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Vincent Crabbe', '2023-11-01', '23:23', 2);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Draco Malfoy', '2023-11-01', '07:00', 1);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Draco Malfoy', '2023-11-01', '14:00', 2);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Harry Potter', '2023-11-28', '11:59', 1);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Harry Potter', '2023-11-28', '16:00', 2);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Alex Muss', now()::DATE, '10:00', 1);
INSERT INTO TimeTracking(peer, date, time, state) VALUES ('Alex Muss', now()::DATE, '16:00', 2);

CREATE OR REPLACE PROCEDURE prc_export(
    table_name VARCHAR(50),
    source VARCHAR(100),
    delimiter VARCHAR(5) DEFAULT ','
) AS
$export$
BEGIN
    EXECUTE FORMAT('COPY %I TO %L WITH DELIMITER %L CSV HEADER', table_name, source, delimiter);
END;
$export$
LANGUAGE plpgsql;

--CALL prc_export('peers', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\peers.csv', ',');
--CALL prc_export('tasks', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\tasks.csv');
--CALL prc_export('checks', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\checks.csv', ',');
--CALL prc_export('p2p', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\p2p.csv', ',');
--CALL prc_export('verter', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\verter.csv', ',');
--CALL prc_export('xp', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\xp.csv', ',');
--CALL prc_export('transferredpoints', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\transferredpoints.csv', ',');
--CALL prc_export('friends', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\friends.csv', ',');
--CALL prc_export('recommendations', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\recommendations.csv', ',');
--CALL prc_export('timetracking', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Export\timetracking.csv', ',');



CREATE OR REPLACE PROCEDURE prc_import(
    table_name VARCHAR(50),
    source VARCHAR(100),
    delimiter VARCHAR(5) DEFAULT ','
) AS
$import$
BEGIN
    EXECUTE FORMAT('COPY %I FROM %L WITH DELIMITER %L CSV HEADER', table_name, source, delimiter);
END;
$import$
LANGUAGE plpgsql;


--CALL prc_import('peers', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\peers.csv', ',');
--CALL prc_import('tasks', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\tasks.csv');
--CALL prc_import('checks', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\checks.csv', ',');
--CALL prc_import('p2p', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\p2p.csv', ',');
--CALL prc_import('verter', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\verter.csv', ',');
--CALL prc_import('xp', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\xp.csv', ',');
--CALL prc_import('transferredpoints', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\transferredpoints.csv', ',');
--CALL prc_import('friends', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\friends.csv', ',');
--CALL prc_import('recommendations', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\recommendations.csv', ',');
--CALL prc_import('timetracking', 'C:\Users\1\Desktop\SQL2_Info21_v1.0-1\src\Import\timetracking.csv', ',');


-- ==================================================================================================================================================

-- DROP TABLE IF EXISTS Tasks, P2P, Verter, Checks, XP, Peers,
--     TransferredPoints, Friends, Recommendations, TimeTracking CASCADE;

-- CREATE TABLE IF NOT EXISTS Peers (
--     nickname VARCHAR PRIMARY KEY,
--     birthday DATE NOT NULL
-- );

-- CREATE TABLE IF NOT EXISTS Tasks (
--     title_name  VARCHAR NOT NULL PRIMARY KEY,
--     parent_task VARCHAR NULL REFERENCES Tasks(title_name),
--     max_xp INTEGER NOT NULL
-- );

-- CREATE TABLE IF NOT EXISTS Checks (
--     id BIGSERIAL PRIMARY KEY,
--     peer VARCHAR NOT NULL REFERENCES Peers(nickname),
--     task VARCHAR NOT NULL REFERENCES Tasks(title_name),
--     Date DATE NOT NULL
-- );

-- CREATE TABLE IF NOT EXISTS P2P (
--     id BIGSERIAL PRIMARY KEY,
--     check_id BIGINT REFERENCES Checks(id),
--     checking_peer VARCHAR NOT NULL REFERENCES Peers(nickname),
--     state CHECK_STATUS NOT NULL,
--     time TIME NOT NULL,
--     UNIQUE(check_id, checking_peer, state)
-- );

-- CREATE TABLE IF NOT EXISTS Verter (
--     id BIGSERIAL PRIMARY KEY,
--     check_id BIGINT REFERENCES Checks(id),
--     state CHECK_STATUS NOT NULL,
--     time TIME NOT NULL,
--     UNIQUE(check_id, state)
-- );

-- CREATE TABLE IF NOT EXISTS XP (
--     id BIGSERIAL PRIMARY KEY,
--     check_id  BIGINT REFERENCES Checks(id) UNIQUE,
--     xp_amount INTEGER NOT NULL CHECK(xp_amount > 0)
-- );

-- CREATE TABLE IF NOT EXISTS TransferredPoints (
--     id BIGSERIAL PRIMARY KEY,
--     checking_peer  VARCHAR NOT NULL REFERENCES Peers(nickname),
--     checked_peer  VARCHAR NOT NULL REFERENCES Peers(nickname),
--     points_amount INTEGER NOT NULL CHECK(points_amount > 0),
--     UNIQUE(checking_peer, checked_peer)
-- );

-- CREATE TABLE IF NOT EXISTS Friends (
--     id BIGSERIAL PRIMARY KEY,
--     peer1 VARCHAR NOT NULL REFERENCES Peers(nickname),
--     peer2 VARCHAR NOT NULL REFERENCES Peers(nickname),
--     UNIQUE(peer1, peer2)
-- );

-- CREATE TABLE IF NOT EXISTS Recommendations (
--     id BIGSERIAL PRIMARY KEY,
--     peer VARCHAR NOT NULL REFERENCES Peers(nickname),
--     recommended_peer VARCHAR NOT NULL REFERENCES Peers(nickname) CHECK(recommended_peer <> peer),
--     UNIQUE(peer, recommended_peer)
-- );

-- CREATE TABLE IF NOT EXISTS TimeTracking (
--     id BIGSERIAL PRIMARY KEY,
--     peer VARCHAR NOT NULL REFERENCES Peers(nickname),
--     date DATE NOT NULL,
--     time TIME NOT NULL,
--     state INTEGER NOT NULL CHECK(state IN (1, 2)),
--     UNIQUE(peer, date, time)
-- );
--select * from checks
--select * from verter
