 -- Create a database for the NFL app
 -- use master;

-- --CREATE DATABASE NFL_ROB_Matey;
-- drop database NFL_ROB_Matey;

 -- Create database MIST353_NFL_RDB_Matey;
use MIST353_NFL_RDB_Matey;

if(OBJECT_ID('Team') IS NOT NULL) -- this is a check to see if the Team table already exists, if it does, it will drop the table before creating it again (this is useful for testing and development)
drop table Team;
if(OBJECT_ID('ConferenceDivision') IS NOT NULL) -- this is a check to see if the ConferenceDivision table already exists, if it does, it will drop the table before creating it again (this is useful for testing and development)
    drop table ConferenceDivision;

-- Create table for first iteration
go 

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

