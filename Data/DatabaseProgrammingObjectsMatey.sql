-- 3 queries
-- 1 each for ConferenceDivision and Team tables, and 1 join query

-- MIST353_NFL_RDB_Matey;
--Use [mist353-nfl-matey]; 

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

-- EXEC dbo.procGetTeamsByConferenceDivision
--   @ConferenceName = 'AFC',
--   @DivisionName = 'North';

--Find all teams in my team’s division (user optionally provides their team name)
-- Add ConferenceName and DivisionName 

CREATE OR ALTER PROCEDURE dbo.procGetTeamsInSameConferenceDivisionAsSpecifiedTeam
(
    @TeamName NVARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT OtherTeam.TeamName, CD.Conference, CD.Division
    FROM dbo.Team MyTeam
    INNER JOIN dbo.Team OtherTeam
        ON MyTeam.ConferenceDivisionID = OtherTeam.ConferenceDivisionID
    INNER JOIN dbo.ConferenceDivision CD
        ON MyTeam.ConferenceDivisionID = CD.ConferenceDivisionID
    WHERE MyTeam.TeamName = @TeamName
      AND OtherTeam.TeamName != @TeamName;
END;
GO
EXEC dbo.procGetTeamsInSameConferenceDivisionAsSpecifiedTeam
    @TeamName = 'Miami Dolphins';


-- go 
select * from Team;
declare @myTeamName nvarchar(50) = 'Pittsburgh Steelers';
select OtherTeam.TeamName
from Team MyTeam inner join Team OtherTeam
on MyTeam.ConferenceDivisionID = OtherTeam.ConferenceDivisionID --this pairs up the teams based on their ConferenceDivisionID, it allows us to find all the teams that are in the same division as the specified team
where MyTeam.TeamName = @myTeamName -- filters the results to only include rows where the TeamName column in the MyTeam table is equal to the value of the @myTeamName variable, it allows us to find the ConferenceDivisionID for the specified team
and OtherTeam.TeamName != @myTeamName; -- this is a command to filter the results to only include rows where the TeamName column in the OtherTeam table is equal to the value of the @myTeamName variable, it allows us to find the ConferenceDivisionID for the specified team and then find all other teams that have the same ConferenceDivisionID (i.e., all teams in the same division as the specified team)


--Find all teams in my team’s division (user optionally provides their team name)
-- Add ConferenceName and DivisionName

go 
select * from Team;
declare @myTeamName nvarchar(50) = 'Miami Dolphins';
select OtherTeam.TeamName, ConferenceDivision.Conference, ConferenceDivision.Division
from Team MyTeam inner join Team OtherTeam
on MyTeam.ConferenceDivisionID = OtherTeam.ConferenceDivisionID 
inner join ConferenceDivision -- this joins the ConferenceDivision table to the results of the previous join, it allows us to get the conference and division information for the teams we are selecting
on MyTeam.ConferenceDivisionID = ConferenceDivision.ConferenceDivisionID -- this joins the ConferenceDivision table so we can display the Conference and Division names 
where MyTeam.TeamName = @myTeamName 
and OtherTeam.TeamName != @myTeamName; 

-- Added: these added the Conference and Division names to the results of the query
-- select: ConferenceDivision.Conference, ConferenceDivision.Division
-- inner join ConferenceDivision 
-- on MyTeam.ConferenceDivisionID = ConferenceDivision.ConferenceDivisionID 
 
 GO

 create or alter procedure procValidateUser
(
  @Email NVARCHAR(100),
  @PasswordHash NVARCHAR(200)
)
AS
BEGIN
  select AppUserID, Firstname + ' ' + Lastname as Fullname, UserRole
  from AppUser
  where Email = @Email and 
PasswordHash = Convert(VARBINARY(200), @PasswordHash, 1);

END
-- EXEC procValidateUser @Email = 'tom.brady@example.com', @PasswordHash = '0x01';

GO

CREATE OR ALTER PROCEDURE procGetTeamsForSpecifiedFan
(
    @NFLFanID INT
)
AS
BEGIN
    SELECT 
        T.TeamName, CD.Conference, CD.Division, T.TeamColors
    FROM NFLFan F
    INNER JOIN FanTeam FT
        ON F.NFLFanID = FT.NFLFanID
    INNER JOIN Team T
        ON FT.TeamID = T.TeamID
    INNER JOIN ConferenceDivision CD
        ON T.ConferenceDivisionID = CD.ConferenceDivisionID
    WHERE F.NFLFanID = @NFLFanID;
END

-- execute procGetTeamsForSpecifiedFan @NFLFanID = 1;
-- execute procGetTeamsForSpecifiedFan @NFLFanID = 2;


create or alter procedure procGetTeamsByFanID
@FanID INT
AS
BEGIN
select T.TeamName, CD. Conference, CD.Division, T.TeamColors, FT.PrimaryTeam 
from FanTeam FT inner join Team T
on FT. TeamID = T.TeamID
inner join ConferenceDivision CD
on T.ConferenceDivisionID = CD.ConferenceDivisionID
where FT.NFLFanID = @FanID;
END

-- execute procGetTeamsByFanID @FanID = 1;
-- execute procGetTeamsByFanID @FanID = 2;
-- execute procGetTeamsByFanID @FanID = 3;









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


