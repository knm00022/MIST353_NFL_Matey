-- Insert Data
-- Insert all the ConferenceDivision data (8 rows) 
-- Insert data for AFC North (4 rows) 

use MIST353_NFL_RDB_Matey;
insert into ConferenceDivision(Conference, Division)
values ('AFC', 'North'),
       ('AFC', 'South'),
       ('AFC', 'East'),
       ('AFC', 'West'),
       ('NFC', 'North'),
       ('NFC', 'South'),
       ('NFC', 'East'),
       ('NFC', 'West');

Go
select * from ConferenceDivision order by ConferenceDivisionID; -- this is a command to select all the data from the ConferenceDivision table, it allows us to see the data we just inserted (this is useful for testing and development)

GO
insert Team (TeamName, TeamCityState, TeamColors, ConferenceDivisionID)
-- seperated by conference and division for readability, but it is not necessary to do so, you could insert all the data in one statement if you wanted to (but it would be harder to read and maintain)
values ('Baltimore Ravens', 'Baltimore, MD', 'Purple, Black', 1),
       ('Cleveland Browns', 'Cleveland, OH', 'Brown, White', 1),
       ('Pittsburgh Steelers', 'Pittsburgh, PA', 'Yellow, Black', 1),
       ('Cincinnati Bengals', 'Cincinnati, OH', 'Orange, Black', 1),

       ('Houston Texans', 'Houston, TX', 'Red, White', 2),
       ('Jacksonville Jaguars', 'Jacksonville, FL', 'Blue, White, Gold', 2),
       ('Indianapolis Colts', 'Indianapolis, IN', 'Blue, White, Gold', 2),
       ('Tennessee Titans', 'Nashville, TN', 'Orange, White, Blue', 2),

       ('Buffalo Bills', 'Buffalo, NY', 'Blue, White, Golden Yellow ', 3),
       ('Miami Dolphins', 'Miami, FL ', 'Blue, Orange, White ', 3),
       ('New England Patriots ', 'Foxborough, MA ', 'Green, White ', 3),
       ('New York Jets ', 'New York City, NY ', 'Blue, White, Golden Yellow ', 3),

       ('Denver Broncos ', 'Denver, CO ', 'Orange, Dark Blue ', 4),
       ('Kansas City Chiefs ', 'Kansas City, MO ', 'Red, Light Blue, Golden Yellow ', 4),
       ('Las Vegas Raiders ', 'Las Vegas, NV ', 'Silver, Black ', 4),
       ('Los Angeles Chargers ', 'Los Angeles, CA ', 'Light Blue, Yellow, White ', 4),
    
         ('Chicago Bears ', 'Chicago, IL ', 'Navy Blue, Orange, White ', 5),
         ('Detroit Lions ', 'Detroit, MI ', 'Blue, Silver, White ', 5),
         ('Green Bay Packers ', 'Green Bay, WI ', 'Green, Yellow, White ', 5),
         ('Minnesota Vikings ', 'Minneapolis, MN ', 'Purple, Gold, White', 5),
    
         ('Atlanta Falcons', 'Atlanta, GA', 'Red, Black, Silver', 6),
         ('Carolina Panthers', 'Charlotte, NC', 'Black, Silver, Blue', 6),
         ('New Orleans Saints', 'New Orleans, LA', 'Black, Gold, White', 6),
         ('Tampa Bay Buccaneers', 'Tampa Bay, FL', 'Red, Pewter, Silver, White', 6),
    
         ('Dallas Cowboys', 'Dallas, TX', 'Silver, Navy Blue, White', 7),
         ('New York Giants', 'New York City, NY', 'Blue, Red, White', 7),
         ('Philadelphia Eagles', 'Philadelphia, PA', 'Green, Silver, White', 7),
         ('Washington Commanders', 'Washington D.C.', 'Burgundy, Gold, White', 7),
    
         ('Arizona Cardinals', 'Phoenix, AZ', 'Red, Purple, Solid White, Grey', 8),
         ('Los Angeles Rams', 'Los Angeles, CA', 'Royal Blue, Solid Yellow, Solid White, Grey', 8),
         ('San Francisco 49ers', 'San Francisco, CA', 'Red, Solid Gold, Solid White, Grey', 8),
         ('Seattle Seahawks', 'Seattle, WA', 'Navy Blue, Solid Green, Solid White, Grey ', 8);

