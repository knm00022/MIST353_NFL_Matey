-- 3 queries
-- 1 each for ConferenceDivision and Team tables, and 1 join query

-- MIST353_NFL_RDB_Matey;
--Use [mist353-nfl-matey]; 

-- -- Query 1
-- -- Display all conferences and divisions
-- SELECT ConferenceDivisionID, Conference, Division -- this is a command to select the ConferenceDivisionID, Conference, and Division columns from the ConferenceDivision table, it allows us to see all the conferences and divisions we have in our database
-- FROM ConferenceDivision -- this is the name of the table we are selecting from
-- ORDER BY Conference, Division; -- this is a command to order the results by Conference and Division, it allows us to see the conferences and divisions in a logical order (AFC North, AFC South, etc.)

-- -- Query 2
-- -- Display all teams
-- SELECT TeamID, TeamName, TeamCityState, TeamColors, ConferenceDivisionID -- this is a command to select the TeamID, TeamName, TeamCityState, TeamColors, and ConferenceDivisionID columns from the Team table, it allows us to see all the teams we have in our database
-- FROM Team -- this is the name of the table we are selecting from
-- ORDER BY ConferenceDivisionID, TeamName; -- this is a command to order the results by ConferenceDivisionID and TeamName, it allows us to see the teams in a logical order (all the teams in AFC North together, all the teams in AFC South together, etc.)

-- -- Query 3 
-- -- Join Team with ConferenceDivision
-- SELECT Team.TeamName, Team.TeamCityState, ConferenceDivision.Conference, ConferenceDivision.Division, Team.TeamColors -- this is a command to select the TeamName, TeamCityState, Conference, Division, and TeamColors columns from the Team and ConferenceDivision tables, it allows us to see all the teams along with their conference and division information
-- FROM Team -- this is the name of the first table we are selecting from (the Team table)
-- JOIN ConferenceDivision -- this is a command to join the Team table with the ConferenceDivision table, it allows us to combine the data from both tables based on a common column (ConferenceDivisionID)
--     ON Team.ConferenceDivisionID = ConferenceDivision.ConferenceDivisionID -- this is a command to specify the condition for the join, it ensures that we are joining the rows from the Team table with the corresponding rows from the ConferenceDivision table based on the ConferenceDivisionID column
-- ORDER BY ConferenceDivision.Conference, ConferenceDivision.Division, Team.TeamName; -- this is a command to order the results by Conference, Division, and TeamName, it allows us to see the teams in a logical order (all the teams in AFC North together, all the teams in AFC South together, etc.)

-- -- Extra Query Practice
-- -- Display only AFC teams
-- SELECT Team.TeamName, Team.TeamCityState, ConferenceDivision.Conference, ConferenceDivision.Division -- this is a command to select the TeamName, TeamCityState, Conference, and Division columns from the Team and ConferenceDivision tables, it allows us to see all the teams along with their conference and division information
-- FROM Team -- this is the name of the first table we are selecting from (the Team table)
-- JOIN ConferenceDivision -- this is a command to join the Team table with the ConferenceDivision table, it allows us to combine the data from both tables based on a common column (ConferenceDivisionID)
--     ON Team.ConferenceDivisionID = ConferenceDivision.ConferenceDivisionID -- this is a command to specify the condition for the join, it ensures that we are joining the rows from the Team table with the corresponding rows from the ConferenceDivision table based on the ConferenceDivisionID column
-- WHERE ConferenceDivision.Conference = 'AFC' -- this is a command to filter the results to only include rows where the Conference column in the ConferenceDivision table is equal to 'AFC', it allows us to see only the teams that are in the AFC conference
-- ORDER BY ConferenceDivision.Conference, ConferenceDivision.Division, Team.TeamName; -- this is a command to order the results by Conference, Division, and TeamName, it allows us to see

-- -- Display only AFC North teams
-- SELECT Team.TeamName, Team.TeamCityState, ConferenceDivision.Conference, ConferenceDivision.Division -- this is a command to select the TeamName, TeamCityState, Conference, and Division columns from the Team and ConferenceDivision tables, it allows us to see all the teams along with their conference and division information
-- FROM Team -- this is the name of the first table we are selecting from (the Team table)
-- JOIN ConferenceDivision -- this is a command to join the Team table with the ConferenceDivision table, it allows us to combine the data from both tables based on a common column (ConferenceDivisionID)
--     ON Team.ConferenceDivisionID = ConferenceDivision.ConferenceDivisionID -- this is a command to specify the condition for the join, it ensures that we are joining the rows from the Team table with the corresponding rows from the ConferenceDivision table based on the ConferenceDivisionID column
-- WHERE ConferenceDivision.Conference = 'AFC' AND ConferenceDivision.Division = 'North' -- this is a command to filter the results to only include rows where the Conference column in the ConferenceDivision table is equal to 'AFC' and the Division column in the ConferenceDivision table is equal to 'North', it allows us to see only the teams that are in the AFC North division
-- ORDER BY ConferenceDivision.Conference, ConferenceDivision.Division, Team.TeamName; -- this is a command to order the results by Conference, Division, and TeamName, it allows us to see the teams in a logical order (all the teams in AFC North together, all the teams in AFC South together, etc.)

-- In Class examples:
-- 1. User searchers for teams using Conference name (optional) and / or Divion name (optional)
-- To show: teamname, conferencename, divisionname

-- SELECT COUNT(*) AS ConferenceDivisionCount FROM dbo.ConferenceDivision;
-- SELECT COUNT(*) AS TeamCount FROM dbo.Team;
-- go
-- create or alter procedure procGetTeamsByConferenceDivision
-- (
--     @ConferenceName NVARCHAR(50) = NULL, -- this is a parameter for the conference name, it is optional (it can be NULL)
--     @DivisionName NVARCHAR(50) = NULL -- this is a parameter for the division name, it is optional (it can be NULL)
--  )
--   AS
--   begin
-- SELECT TeamName, TeamColors, Conference, Division 
-- FROM Team T inner join ConferenceDivision C 
-- on T.ConferenceDivisionID = C.ConferenceDivisionID
-- Where Conference = IsNull(@ConferenceName, Conference) 
-- and Division = IsNull(@DivisionName, Division)
--     end

-- EXEC procGetTeamsByConferenceDivision
-- @ConferenceName = 'AFC',
-- @DivisionName = 'North';
-- go

CREATE OR ALTER PROCEDURE dbo.procGetTeamsByConferenceDivision
(
    @ConferenceName NVARCHAR(50) = NULL,
    @DivisionName   NVARCHAR(50) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT T.TeamName, T.TeamColors, C.Conference, C.Division
    FROM dbo.Team T
    INNER JOIN dbo.ConferenceDivision C
        ON T.ConferenceDivisionID = C.ConferenceDivisionID
    WHERE C.Conference = ISNULL(@ConferenceName, C.Conference)
      AND C.Division   = ISNULL(@DivisionName, C.Division);
END;
GO

EXEC dbo.procGetTeamsByConferenceDivision
  @ConferenceName = 'AFC',
  @DivisionName = 'North';


--Find all teams in my team’s division (user optionally provides their team name)
DECLARE @TeamName NVARCHAR(50) = NULL;  

SET @TeamName = 'Pittsburgh Steelers';

SELECT
    t.TeamName,
    t.TeamColors,
    cd.Conference,
    cd.Division
FROM dbo.Team t
INNER JOIN dbo.ConferenceDivision cd
    ON t.ConferenceDivisionID = cd.ConferenceDivisionID
WHERE t.ConferenceDivisionID = ISNULL(
          (
            SELECT ConferenceDivisionID
            FROM dbo.Team
            WHERE TeamName = @TeamName
          ),
          t.ConferenceDivisionID
      )
ORDER BY t.TeamName;
