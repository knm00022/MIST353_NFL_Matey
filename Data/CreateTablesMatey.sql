 -- Create a database for the NFL app
 -- use master;

-- --CREATE DATABASE NFL_ROB_Matey;
-- drop database NFL_ROB_Matey;


 --Create database MIST353_NFL_RDB_Matey;
--use MIST353_NFL_RDB_Matey;
--use [mist353-nfl-matey];
--use MIST353_NFL_RDB_Matey;


if(OBJECT_ID('AdminChangesTracker') is not null)
    drop table AdminChangesTracker;
if(OBJECT_ID('TeamStadium') is not null)
    drop table TeamStadium;
if(OBJECT_ID('Game') is not null)
    drop table Game;
if(OBJECT_ID('Stadium') is not null)
    drop table Stadium;

if(OBJECT_ID('FanTeam') is not null)
    drop table FanTeam;
if(OBJECT_ID('Team') is not null)
    drop table Team;
if(OBJECT_ID('ConferenceDivision') is not null)
    drop table ConferenceDivision;
if(OBJECT_ID('NFLAdmin') is not null)
    drop table NFLAdmin;
if(OBJECT_ID('NFLFan') is not null)
    drop table NFLFan;
if(OBJECT_ID('AppUser') is not null)
    drop table AppUser;



-- Create table for first iteration
GO

Create TABLE ConferenceDivision (
    ConferenceDivisionID INT identity (1,1)
    constraint PK_ConferenceDivision PRIMARY KEY,
    Conference NVARCHAR (50) NOT NULL 
    constraint CK_ConferenceNames CHECK (Conference IN ('AFC', 'NFC')), -- this is a check constraint, it ensures that the value entered for Conference is either 'AFC' or 'NFC'
    Division NVARCHAR (50) NOT NULL
    constraint CK_DivisionNames CHECK (Division IN ('North', 'South', 'East', 'West')), -- this is a check constraint, it ensures that the value entered for Division is either 'North', 'South', 'East', or 'West'
    constraint UK_ConferenceDivision UNIQUE (Conference, Division) -- this is a unique constraint, it ensures that the combination of Conference and Division is unique (no duplicate rows)

);

-- alter table ConferenceDivision
--     NOCHECK CONSTRAINT CK_ConferenceNames; -- this is a command to disable the check constraint CK_ConferenceNames, it allows us to insert data that does not meet the check constraint (we will re-enable it after we insert the data)

-- alter table ConferenceDivision
--     CHECK CONSTRAINT CK_DivisionNames; -- this is a command to disable the check constraint CK_DivisionNames, it allows us to insert data that does not meet the check constraint (we will re-enable it after we insert the data)
    
go

Create TABLE Team (
    TeamID INT identity (1,1) -- the first team we enter will be 1, the second will be 2, etc. (it increments)
    constraint PK_Team PRIMARY KEY, -- this is the primary key for the table, it uniquely identifies each team
    TeamName NVARCHAR (50) NOT NULL,
    TeamCityState NVARCHAR (50) NOT NULL,
    TeamColors NVARCHAR (100) NOT NULL,
    ConferenceDivisionID INT NOT NULL, -- this is a foreign key that references the ConferenceDivisionID in the ConferenceDivision table
    constraint FK_Team_ConferenceDivision FOREIGN KEY (ConferenceDivisionID) REFERENCES ConferenceDivision -- this is the foreign key constraint, it ensures that the value entered for ConferenceDivisionID in the Team table must exist in the ConferenceDivision table (it creates a relationship between the two tables)
);

GO
-- Create table for second iteration

create table AppUser (
    AppUserID INT identity (1,1) 
        constraint PK_AppUser PRIMARY KEY,
    Firstname NVARCHAR (50) NOT NULL,
    Lastname NVARCHAR (50) NOT NULL,
    Email NVARCHAR (100) NOT NULL
        constraint UK_AppUserEmail UNIQUE,
    PasswordHash VARBINARY (200) NOT NULL,
    Phone VARCHAR (20) NULL,
    UserRole NVARCHAR (50) NOT NULL
        constraint CK_UserRole CHECK (UserRole IN (N'NFLAdmin', N'NFLFan'))

);

GO 

create table NFLFan(
    NFLFanID INT
        constraint PK_NFLFan PRIMARY KEY
        constraint FK_NFLFan_AppUser FOREIGN KEY REFERENCES AppUser(AppUserID)
);

GO

create table NFLAdmin(
    NFLAdminID INT
        constraint PK_NFLAdmin PRIMARY KEY
        constraint FK_NFLAdmin_AppUser FOREIGN KEY REFERENCES AppUser(AppUserID)
);

GO 

create table FanTeam(
    FanTeamID INT identity (1,1)
        constraint PK_FanTeam PRIMARY KEY,
    NFLFanID INT NOT NULL
        constraint FK_FanTeam_NFLFan FOREIGN KEY REFERENCES NFLFan(NFLFanID),
    TeamID INT NOT NULL
        constraint FK_FanTeam_Team FOREIGN KEY REFERENCES Team(TeamID),
        constraint UK_FanTeam UNIQUE (NFLFanID, TeamID),
    PrimaryTeam BIT NOT NULL
);

go

create table Stadium (
    StadiumID INT identity(1,1) 
        constraint PK_Stadium PRIMARY KEY,
    StadiumName NVARCHAR(100) NOT NULL,
    StadiumCityState NVARCHAR(50) NOT NULL,
    Capacity INT NOT NULL
);

go

create table TeamStadium (
    TeamStadiumID INT identity(1,1) 
        constraint PK_TeamStadium PRIMARY KEY,
    TeamID INT NOT NULL 
        constraint FK_TeamStadium_Team FOREIGN KEY REFERENCES Team(TeamID),
    StadiumID INT NOT NULL
        constraint FK_TeamStadium_Stadium FOREIGN KEY REFERENCES Stadium(StadiumID),
    StartYear INT NOT NULL,
    EndYear INT NULL,
    constraint UK_TeamStadium UNIQUE (TeamID, StadiumID, StartYear)
);

go

create table Game (
    GameID INT identity(1,1) 
        constraint PK_Game PRIMARY KEY,
    GameRound NVARCHAR(50) NOT NULL
        constraint CK_GameRound CHECK (GameRound IN ('Wild Card', 'Divisional', 'Conference', 'Super Bowl')),
    GameDate DATE NOT NULL,
    GameStartTime TIME NOT NULL,
    HomeTeamID INT NOT NULL 
        constraint FK_Game_HomeTeam FOREIGN KEY REFERENCES Team(TeamID),
    AwayTeamID INT NOT NULL
        constraint FK_Game_AwayTeam FOREIGN KEY REFERENCES Team(TeamID),
    StadiumID INT NOT NULL
        constraint FK_Game_Stadium FOREIGN KEY REFERENCES Stadium(StadiumID),
    HomeTeamScore INT NULL,
    AwayTeamScore INT NULL,
    WinningTeamID INT NULL
        constraint FK_Game_WinningTeam FOREIGN KEY REFERENCES Team(TeamID),
    constraint CK_Game_Teams CHECK (HomeTeamID != AwayTeamID),
    constraint UK_Game UNIQUE (HomeTeamID, AwayTeamID, GameDate)
);

go

create table AdminChangesTracker (
    AdminChangesTrackerID INT identity(1,1) 
        constraint PK_AdminChangesTracker PRIMARY KEY,
    NFLAdminID INT NOT NULL
        constraint FK_AdminChangesTracker_NFLAdmin FOREIGN KEY REFERENCES NFLAdmin(NFLAdminID),
    GameID INT NOT NULL
        constraint FK_AdminChangesTracker_Game FOREIGN KEY REFERENCES Game(GameID),
    ChangeDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    ChangeType NVARCHAR(50) NOT NULL
        constraint CK_AdminChangesTracker_ChangeType CHECK (ChangeType IN (N'Insert', N'Update', N'Delete')),
    ChangeDescription NVARCHAR(500) NOT NULL
);
