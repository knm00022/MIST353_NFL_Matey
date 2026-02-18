-- 3 queries
-- 1 each for ConferenceDivision and Team tables, and 1 join query

Use MIST353_NFL_RDB_Matey;

-- Query 1: Display all conferences and divisions
SELECT ConferenceDivisionID, Conference, Division
FROM ConferenceDivision
ORDER BY Conference, Division; 

-- Query 2: Display all teams
SELECT
    TeamID,
    TeamName,
    TeamCityState,
    TeamColors,
    ConferenceDivisionID
FROM Team
ORDER BY ConferenceDivisionID, TeamName;

-- Query 3: Join Team with ConferenceDivision
SELECT
    t.TeamName,
    t.TeamCityState,
    cd.Conference,
    cd.Division,
    t.TeamColors
FROM Team t
INNER JOIN ConferenceDivision cd
    ON t.ConferenceDivisionID = cd.ConferenceDivisionID
ORDER BY cd.Conference, cd.Division, t.TeamName;