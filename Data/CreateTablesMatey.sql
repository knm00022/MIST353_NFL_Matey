 -- Create a database for the NFL app
 -- use master;

-- --CREATE DATABASE NFL_ROB_Matey;
-- drop database NFL_ROB_Matey;

 -- Create database MIST353_NFL_RDB_Matey;
use MIST353_NFL_RDB_Matey;

-- Create table for first iteration
go 


Create TABLE ConferenceDivison (
    ConferenceDivisionID INT identity (1,1)
    constraint PK_ConferenceDivision PRIMARY KEY,
    Conference NVARCHAR (50) NOT NULL 
    constraint CK_Conference CHECK (Conference IN ('AFC', 'NFC')), -- this is a check constraint, it ensures that the value entered for Conference is either 'AFC' or 'NFC'
    Division NVARCHAR (50) NOT NULL
    constraint CK_Division CHECK (Division IN ('North', 'South', 'East', 'West')) -- this is a check constraint, it ensures that the value entered for Division is either 'North', 'South', 'East', or 'West'

);

Create TABLE Team (
    TeamID INT identity (1,1) -- the first team we enter will be 1, the second will be 2, etc. (it increments)
    constraint PK_Team PRIMARY KEY, -- this is the primary key for the table, it uniquely identifies each team
    TeamName NVARCHAR (50) NOT NULL,
    TeamCityState NVARCHAR (50) NOT NULL,
    TeamColors NVARCHAR (50) NOT NULL,
    ConferenceDivisionID INT NOT NULL, -- this is a foreign key that references the ConferenceDivisionID in the ConferenceDivison table
    constraint FK_Team_ConferenceDivision FOREIGN KEY (ConferenceDivisionID) REFERENCES ConferenceDivison
);
 