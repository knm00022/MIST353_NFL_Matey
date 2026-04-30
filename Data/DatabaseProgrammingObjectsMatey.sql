
-- MIST353_NFL_RDB_Matey;
--Use [mist353-nfl-matey]; 

GO

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
-- EXEC dbo.procGetTeamsInSameConferenceDivisionAsSpecifiedTeam
--     @TeamName = 'Miami Dolphins';

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
-- EXEC procValidateUser @Email = 'bill.belichick@example.com', @PasswordHash = '0x01';

GO

create or alter procedure procGetTeamsForSpecifiedFan
(
    @NFLFanID INT
)
AS
BEGIN
    select T.TeamName, CD.Conference, CD.Division, T.TeamColors, FT.PrimaryTeam
    from FanTeam FT inner join Team T
        on FT.TeamID = T.TeamID
        inner join ConferenceDivision CD
        on T.ConferenceDivisionID = CD.ConferenceDivisionID
    where FT.NFLFanID = @NFLFanID;
end;

-- execute procGetTeamsForSpecifiedFan @NFLFanID = 1;
-- execute procGetTeamsForSpecifiedFan @NFLFanID = 2;

go

create or alter procedure procScheduleGame
(
    @HomeTeamID INT,
    @AwayTeamID INT,
    @GameRound NVARCHAR(50),
    @GameDate DATE,
    @GameStartTime TIME,
    @StadiumID INT,
    @NFLAdminID INT -- the logged-in admin who is scheduling the game
)
AS
BEGIN
    -- Store the NFLAdminID in context so that the trigger can access it when inserting into AdminChangesTracker
    declare @context VARBINARY(128) = cast(@NFLAdminID as VARBINARY(128)); -- int is only 4 bytes, but context_info can store up to 128 bytes, so we can store additional info in the future if needed
    SET context_info @context;

    insert into Game (HomeTeamID, AwayTeamID, GameRound, GameDate, GameStartTime, StadiumID)
    values (@HomeTeamID, @AwayTeamID, @GameRound, @GameDate, @GameStartTime, @StadiumID);
END

/*
GameRound: 'Wild Card', HomeTeamID: 22, AwayTeamID: 30, GameDate: '2026-01-10', GameStartTime: '16:30', StadiumID: 22, 
NFLAdminID for scheduling: 5 (Bill Belichick)

execute procScheduleGame 
    @HomeTeamID = 22, 
    @AwayTeamID = 30, 
    @GameRound = 'Wild Card', 
    @GameDate = '2026-01-10', 
    @GameStartTime = '16:30', 
    @StadiumID = 22, 
    @NFLAdminID = 5;


GameRound: 'Wild Card', HomeTeamID: 17, AwayTeamID: 19, GameDate: '2026-01-10', GameStartTime: '20:00', StadiumID: 17,
NFLAdminID for scheduling: 6 (Sean McVay)

execute procScheduleGame 
    @HomeTeamID = 17, 
    @AwayTeamID = 19, 
    @GameRound = 'Wild Card', 
    @GameDate = '2026-01-10', 
    @GameStartTime = '20:00', 
    @StadiumID = 17, 
    @NFLAdminID = 6;


select * from Game order by GameID desc;
select * from AdminChangesTracker order by AdminChangesTrackerID desc;


*/

-- trigger to track changes made by NFLAdmin to the Game table
-- 1. triggering event (insert, update, delete) on Game table
-- 2. action: insert a record into AdminChangesTracker with NFLAdminID, GameID, ChangeType, ChangeDescription

GO

create or alter trigger trgTrackChangesOnSchedulingGame
on Game
after insert
as
BEGIN
    declare @NFLAdminID INT;
    declare @GameID INT;
    declare @ChangeType NVARCHAR(50);
    declare @ChangeDescription NVARCHAR(500);
    declare @GameRound NVARCHAR(50);
    declare @GameDate DATE;
    declare @GameStartTime TIME;
    declare @HomeTeamID INT;
    declare @AwayTeamID INT;
    declare @HomeTeamName NVARCHAR(50);
    declare @AwayTeamName NVARCHAR(50);
    declare @StadiumID INT;
    declare @StadiumName NVARCHAR(100);
    declare @AdminFullName NVARCHAR(100);

    -- get the NFLAdminID from context
    set @NFLAdminID = convert(int, convert(binary(4),context_info()));

    -- get the GameID of the newly inserted game
    select @GameID = GameID, @GameRound = GameRound, @GameDate = GameDate, @GameStartTime = GameStartTime, 
        @HomeTeamID = HomeTeamID, @AwayTeamID = AwayTeamID, @StadiumID = StadiumID
    from inserted;
    select @HomeTeamName = TeamName from Team where TeamID = @HomeTeamID;
    select @AwayTeamName = TeamName from Team where TeamID = @AwayTeamID;
    select @StadiumName = StadiumName from Stadium where StadiumID = @StadiumID;
    select @AdminFullName = Firstname + ' ' + Lastname from AppUser where AppUserID = @NFLAdminID;

    set @ChangeType = 'Insert';
    set @ChangeDescription = @AdminFullName + ' scheduled a new game with GameID ' + cast(@GameID as NVARCHAR(50))
        + ': ' + @HomeTeamName + ' vs ' + @AwayTeamName + ' on ' + cast(@GameDate as NVARCHAR(50)) 
        + ' at ' + cast(@GameStartTime as NVARCHAR(50)) + ' in stadium  ' + @StadiumName
        + '. Game round: ' + @GameRound;

    insert into AdminChangesTracker (NFLAdminID, GameID, ChangeType, ChangeDescription)
    values (@NFLAdminID, @GameID, @ChangeType, @ChangeDescription);
END



GO

CREATE OR ALTER PROCEDURE procEnterScores
(
    @GameID INT,
    @HomeTeamScore INT,
    @AwayTeamScore INT,
    @NFLAdminID INT
)
AS
BEGIN
    DECLARE @WinningTeamID INT;

    SELECT @WinningTeamID =
        CASE
            WHEN @HomeTeamScore > @AwayTeamScore THEN HomeTeamID
            WHEN @AwayTeamScore > @HomeTeamScore THEN AwayTeamID
            ELSE NULL
        END
    FROM Game
    WHERE GameID = @GameID;

    DECLARE @context VARBINARY(128) = CAST(@NFLAdminID AS VARBINARY(128));
    SET CONTEXT_INFO @context;

    UPDATE Game
    SET HomeTeamScore = @HomeTeamScore,
        AwayTeamScore = @AwayTeamScore,
        WinningTeamID = @WinningTeamID
    WHERE GameID = @GameID;
END


GO

CREATE OR ALTER TRIGGER trgTrackChangesOnEnteringScores
ON Game
AFTER UPDATE
AS
BEGIN
    DECLARE @NFLAdminID INT;
    DECLARE @GameID INT;
    DECLARE @ChangeType NVARCHAR(50);
    DECLARE @ChangeDescription NVARCHAR(500);
    DECLARE @HomeTeamScore INT;
    DECLARE @AwayTeamScore INT;
    DECLARE @HomeTeamID INT;
    DECLARE @AwayTeamID INT;
    DECLARE @HomeTeamName NVARCHAR(50);
    DECLARE @AwayTeamName NVARCHAR(50);

    SET @NFLAdminID = CONVERT(INT, CONVERT(BINARY(4), CONTEXT_INFO()));

    SELECT 
        @GameID = GameID,
        @HomeTeamScore = HomeTeamScore,
        @AwayTeamScore = AwayTeamScore,
        @HomeTeamID = HomeTeamID,
        @AwayTeamID = AwayTeamID
    FROM inserted;

    SELECT @HomeTeamName = TeamName FROM Team WHERE TeamID = @HomeTeamID;
    SELECT @AwayTeamName = TeamName FROM Team WHERE TeamID = @AwayTeamID;

    SET @ChangeType = 'Update';

    SET @ChangeDescription = 'Scores updated for GameID=' + CAST(@GameID AS NVARCHAR(50)) + ': '
        + @HomeTeamName + ' scored ' + CAST(@HomeTeamScore AS NVARCHAR(50)) + ', '
        + @AwayTeamName + ' scored ' + CAST(@AwayTeamScore AS NVARCHAR(50));

    INSERT INTO AdminChangesTracker (NFLAdminID, GameID, ChangeType, ChangeDescription)
    VALUES (@NFLAdminID, @GameID, @ChangeType, @ChangeDescription);
END
GO

GO

CREATE OR ALTER PROCEDURE procGetAllChangesMadeBySpecifiedAdmin
(
    @NFLAdminID INT
)
AS
BEGIN
    SELECT 
        ACT.ChangeDateTime,
        ACT.ChangeType,
        ACT.ChangeDescription,
        G.GameRound,
        G.GameDate,
        G.GameStartTime,
        HT.TeamName AS HomeTeam,
        AT.TeamName AS AwayTeam,
        S.StadiumName
    FROM AdminChangesTracker ACT
    INNER JOIN Game G
        ON ACT.GameID = G.GameID
    INNER JOIN Team HT
        ON G.HomeTeamID = HT.TeamID
    INNER JOIN Team AT
        ON G.AwayTeamID = AT.TeamID
    INNER JOIN Stadium S
        ON G.StadiumID = S.StadiumID
    WHERE ACT.NFLAdminID = @NFLAdminID
    ORDER BY ACT.ChangeDateTime DESC;
END
GO

-- EXEC procGetAllChangesMadeBySpecifiedAdmin @NFLAdminID = 5;


-- ###############################################################################
-- SCRIPT ADDITIONS AND CHANGES FOR 30 APRIL 2026


-- To create dropdown lists for the NFLAdmin to select Teams and Stadiums to schedule games.

create or alter procedure procGetAllTeams
as
begin
    select TeamID, TeamName
    from Team
end
-- execute procGetAllTeams;

go

create or alter procedure procGetAllStadiums
as
begin
    select StadiumID, StadiumName
    from Stadium
end
-- execute procGetAllStadiums;


go

-- Disabling and enabling triggers on the Game table. When and Why?

-- disable trigger trgTrackChangesOnSchedulingGame on Game;
-- disable trigger all on Game;

-- enable trigger trgTrackChangesOnSchedulingGame on Game;
-- enable trigger all on Game;

go

-- Adding TeamLogo column to Team table and creating stored procedure to get teams with logos for a specified fan

alter table Team
add TeamLogo VARBINARY(MAX);

go

create or alter procedure procGetTeamsWithLogosForSpecifiedFan
(
    @NFLFanID INT
)
AS
BEGIN
    select T.TeamName, CD.Conference, CD.Division, T.TeamColors, FT.PrimaryTeam, T.TeamLogo
    from FanTeam FT inner join Team T
        on FT.TeamID = T.TeamID
        inner join ConferenceDivision CD
        on T.ConferenceDivisionID = CD.ConferenceDivisionID
    where FT.NFLFanID = @NFLFanID;
end;
-- execute procGetTeamsWithLogosForSpecifiedFan @NFLFanID = 1;

go


















-- -- go 
-- select * from Team;
-- declare @myTeamName nvarchar(50) = 'Pittsburgh Steelers';
-- select OtherTeam.TeamName
-- from Team MyTeam inner join Team OtherTeam
-- on MyTeam.ConferenceDivisionID = OtherTeam.ConferenceDivisionID --this pairs up the teams based on their ConferenceDivisionID, it allows us to find all the teams that are in the same division as the specified team
-- where MyTeam.TeamName = @myTeamName -- filters the results to only include rows where the TeamName column in the MyTeam table is equal to the value of the @myTeamName variable, it allows us to find the ConferenceDivisionID for the specified team
-- and OtherTeam.TeamName != @myTeamName; -- this is a command to filter the results to only include rows where the TeamName column in the OtherTeam table is equal to the value of the @myTeamName variable, it allows us to find the ConferenceDivisionID for the specified team and then find all other teams that have the same ConferenceDivisionID (i.e., all teams in the same division as the specified team)


--Find all teams in my team’s division (user optionally provides their team name)
-- Add ConferenceName and DivisionName

-- go 
-- select * from Team;
-- declare @myTeamName nvarchar(50) = 'Miami Dolphins';
-- select OtherTeam.TeamName, ConferenceDivision.Conference, ConferenceDivision.Division
-- from Team MyTeam inner join Team OtherTeam
-- on MyTeam.ConferenceDivisionID = OtherTeam.ConferenceDivisionID 
-- inner join ConferenceDivision -- this joins the ConferenceDivision table to the results of the previous join, it allows us to get the conference and division information for the teams we are selecting
-- on MyTeam.ConferenceDivisionID = ConferenceDivision.ConferenceDivisionID -- this joins the ConferenceDivision table so we can display the Conference and Division names 
-- where MyTeam.TeamName = @myTeamName 
-- and OtherTeam.TeamName != @myTeamName; 

-- Added: these added the Conference and Division names to the results of the query
-- select: ConferenceDivision.Conference, ConferenceDivision.Division
-- inner join ConferenceDivision 
-- on MyTeam.ConferenceDivisionID = ConferenceDivision.ConferenceDivisionID 
 




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


