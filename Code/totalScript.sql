
-- Created as a MySQL database and ran using the Sequel Pro application on OSX

-- MySQL database with the name Advanced-Databases
create database Advanced-Databases;

-- Switch to the Advanced-Databases database
use Advanced-Databases;

-- Drop the tables if they already exist
drop table Stadiums;
drop table Player_stats;
drop table Matches;
drop table Player;
drop table Teams;
drop table HolderTable;

drop table Fact_Stats;
drop table DimPlayer;
drop table DimTeam;
drop table DimTime;
drop table DimStadium;

drop table player_stage;
drop table fact_stage;
drop table stadium_stage;
drop table team_stage;
drop table time_stage;

-- Create the tables for the relational model
create table Teams (
  TeamID int not null,
  Team_name varchar(225),
  YearOfFound int,
  primary key (TeamID)
);

create table Player (
  Player_ID int,
  TeamID int,
  PL_name varchar(225),
  PL_surname varchar(225),
  foreign key (TeamID) references Teams(TeamID),
  primary key (Player_ID)
);

create table Stadiums (
  StadiumID int,
  St_name varchar(225),
  City varchar(225),
  Capacity int,
  TeamID int,
  foreign key (TeamID) references Teams(TeamID),
  primary key (StadiumID)
);

create table Matches (
  Team_A varchar(225),
  Team_B varchar(255),
  M_date DATE,
  primary key (Team_A, Team_B, M_date)
);

create table Player_stats (
  Team_A_ID varchar(225),
  Team_B_ID varchar(225),
  Player_ID int,
  M_date DATE,
  MinPlayed int,
  Goals int,
  Shot_on int,
  Shot_off int,
  Penalty int,
  Pass_OK int,
  Pass_KO int,
  foreign key (Team_A_ID, Team_B_ID, M_date) references Matches(Team_A, Team_B, M_date),
  foreign key (Player_ID) references Player(Player_ID)
);


-- Create the holder table for importing from the CSV files
create table HolderTable (
  m_date DATE,
  player_id int,
  player_surname varchar(255),
  player_name varchar(255),
  team_a_name varchar(255),
  team_a_id int,
  team_b_name varchar(255),
  team_b_id int,
  minutes_played int,
  goal int,
  shots_on_target int,
  shots_off_target int,
  penalties int,
  pass_success int,
  pass_fail int
);

-- Insert teams
-- team_id,team_name,year_of_foundation
insert into teams values (11,'Everton',1912);
insert into teams values (1,'Manchester United',1902);
insert into teams values (110,'Stoke City',1908);
insert into teams values (56,'Sunderland',1895);
insert into teams values (54,'Fulham',1887);
insert into teams values (8,'Chelsea',1872);
insert into teams values (111,'Wigan Athletic',1904);
insert into teams values (3,'Arsenal',1888);
insert into teams values (6,'Tottenham Hotspur',1901);
insert into teams values (4,'Newcastle United',1899);
insert into teams values (52,'Queens Park Rangers',1901);
insert into teams values (30,'Bolton Wanderers',1887);
insert into teams values (80,'Swansea City',1900);
insert into teams values (14,'Liverpool',1907);
insert into teams values (35,'West Bromwich Albion',1897);
insert into teams values (39,'Wolverhampton Wanderers',1867);
insert into teams values (45,'Norwich City',1914);
insert into teams values (5,'Blackburn Rovers',	1870	);
insert into teams values (7,'Aston Villa',	1899	);
insert into teams values (43,'Manchester City',	1891	);


-- Insert Stadiums
-- stadiumID,stadium name, city, capacity, team_id (FK)
insert into stadiums values(1,'Old Trafford','Manchester',76100,1);
insert into stadiums values(2,'Emirates Stadium','London',60432,3);
insert into stadiums values(3,'St James'' Park','Newcastle-upon-Tyne',52401,4);
insert into stadiums values(4,'Stadium of Light','Sunderland',49000,56);
insert into stadiums values(5,'Etihad Stadium','Manchester',48000,43);
insert into stadiums values(6,'Anfield','Liverpool',45362,14);
insert into stadiums values(7,'Villa Park','Birmingham',42785,7);
insert into stadiums values(8,'Stamford Bridge','London',41623,8);
insert into stadiums values(9,'Goodison Park','Liverpool',40569,11);
insert into stadiums values(12,'White Hart Lane','London',36274,6);
insert into stadiums values(13,'Craven Cottage','London',25678,54);
insert into stadiums values(14,'DW Stadium','Wigan',25023,111);
insert into stadiums values(15,'Loftus Road','London',18360,52);
insert into stadiums values(16,'Macron Stadium','Horwich',28723,30);
insert into stadiums values(17,'Britannia Stadium','Stoke-on-Trent',28323,110);
insert into stadiums values(18,'Liberty Stadium','Swansea',20700,80);
insert into stadiums values(19,'Carrow Road','Norwich',27220,45);
insert into stadiums values(20,'The Hawthorns','West Bromwich',26500,35);
insert into stadiums values(21,'Molineux','Wolverhampton',31700,39);
insert into stadiums values(22,'Ewood Park','Blackburn',31367,5);


-- Load the csv data into the holderTable using the
load data local infile '~/Premier.csv'
into table HolderTable
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;


-- Move the data from the holder table to the correct tables
-- Insert into Player
insert into Player (Player_ID, TeamID, PL_name, PL_surname)
select distinct player_id, team_a_id, player_name, player_surname from HolderTable where player_id!='0';

-- Insert into Matches
insert into Matches (Team_A, Team_B, M_date)
select distinct team_a_name, team_b_name, m_date from HolderTable where team_a_name!='';

-- Insert into Player_stats
insert into Player_stats (Team_A_ID, Team_B_ID, Player_ID, M_date, MinPlayed, Goals, Shot_on, Shot_off, Penalty, Pass_OK, Pass_KO)
select team_a_name, team_b_name, player_id, m_date, minutes_played, goal, shots_on_target, shots_off_target, penalties, pass_success, pass_fail from HolderTable where player_id!='0' and team_a_name!='';



-- Create the Dimensional tables
create table DimPlayer (
  player_sk int not null auto_increment,
  player_name varchar(255),
  player_surname varchar(255),
  primary key (player_sk)
);

create table DimTeam (
  team_sk int not null auto_increment,
  team_name varchar(255),
  year_of_foundation int,
  primary key (team_sk)
);

create table DimTime (
  date_sk int not null auto_increment ,
  year int,
  month int,
  day int,
  primary key (date_sk)
);

create table DimStadium (
  stadium_sk int not null auto_increment,
  stadium_name varchar(255),
  stadium_city varchar(255),
  capacity int,
  primary key (stadium_sk)
);

-- Fact table
create table Fact_Stats (
  date_sk int,
  player_sk int,
  team_sk int,
  opponent_sk int,
  stadium_sk int,
  min_played int,
  goals int,
  shot_on int,
  shot_off int,
  penalty int,
  pass_ok int,
  pass_ko int,
  foreign key (date_sk) references DimTime(date_sk),
  foreign key (player_sk) references DimPlayer(player_sk),
  foreign key (team_sk) references DimTeam(team_sk),
  foreign key (stadium_sk) references DimStadium(stadium_sk),
  foreign key (opponent_sk) references DimTeam(team_sk)
);


-- Begin the etl process

-- Create the staging tables

-- Insert the information from the relational model to the Dimensional Model

-- Transfer the player data from Player > player_stage > DimPlayer
create table player_stage (
  sourceDB int,
  player_sk int not null auto_increment,
  player_id int,
  player_name varchar(255),
  player_surname varchar(255),
  primary key (player_sk)
);

-- Insert the data into the staging table
insert into player_stage (sourceDB, player_id, player_name, player_surname) select 1, player_id, PL_name, PL_surname from Player;

-- Insert the staged data into the dimensional model
insert into DimPlayer (player_name, player_surname) select player_name, player_surname from player_stage;


-- Transfer the Teams data from Teams > team_stage > DimTeam
create table team_stage (
  team_id int,
  team_sk int not null auto_increment,
  sourceDB int,
  team_name varchar(255),
  year_of_foundation int,
  primary key(team_sk)
);

-- insert the data to the staging table
insert into team_stage (team_id, sourceDB, team_name, year_of_foundation) select TeamID, 1, Team_name, YearOfFound from Teams;

-- insert the data from the staging table into the dimensional model
insert into DimTeam (team_name, year_of_foundation) select team_name, year_of_foundation from team_stage;


-- Transfer the Stadiums data from Stadiums > stadium_stage > DimStadium
create table stadium_stage (
  stadiumID int,
  stadium_sk int not null auto_increment,
  sourceDB int,
  st_name varchar(255),
  city varchar(255),
  capacity int,
  team_id int,
  primary key(stadium_sk)
);

-- Insert the data into the staging table
insert into stadium_stage (stadiumID, sourceDB, st_name, city, capacity, team_id) select StadiumID, 1, St_name, City, Capacity, TeamID from Stadiums;

-- Insert the data into the Dim Table
insert into DimStadium (stadium_sk, stadium_name, stadium_city, capacity) select stadium_sk, st_name, city, capacity from stadium_stage;



-- Transfer the Time data from Matches > time_stage > DimTime
create table time_stage (
  sourceDB int,
  date_sk int not null auto_increment,
  team_a varchar(255),
  team_b varchar(255),
  m_date DATE,
  year int,
  month int,
  day int,
  primary key(date_sk)
);

-- insert data into the staging table
insert into time_stage (sourceDB, team_a, team_b, m_date, year, month, day) select 1, Team_A, Team_B, M_date, extract(year from m_date), extract(month from m_date), extract(day from m_date) from Matches;

-- insert data into the Dim Table
insert into DimTime (date_sk, year, month, day) select date_sk, year, month, day from time_stage;


-- insert the data into the fact table

-- Transfer data from Player_stats > fact_stage > Fact_Stats
create table fact_stage (
  date_sk int,
  player_sk int,
  team_sk int,
  opponent_sk int,
  stadium_sk int,
  sourceDB int,
  team_a_id varchar(255),
  team_b_id varchar(255),
  player_id int,
  m_date date,
  stadium_id int,
  min_played int,
  goals int,
  shot_on int,
  shot_off int,
  penalty int,
  pass_ok int,
  pass_ko int
);


-- insert into the fact_stage table
insert into fact_stage (sourceDB, team_a_id, team_b_id, player_ID, m_date, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko) select 1, Team_A_ID, Team_B_ID, Player_ID, M_date, MinPlayed, Goals, Shot_on, Shot_off, Penalty, Pass_OK, Pass_KO from Player_stats;

-- Update the Fact stage
update fact_stage set stadium_id=(
  select stadium_stage.stadiumID from stadium_stage
  join team_stage on stadium_stage.team_id = team_stage.team_id
  where (
    stadium_stage.sourceDB = fact_stage.sourceDB
    and stadium_stage.team_id = team_stage.team_id
    and team_stage.team_name = fact_stage.team_a_id
  )
);

-- Update the surrogate keys within the fact table

-- Update the player stage
update fact_stage set player_sk=(
  select player_stage.player_sk from player_stage where (
    player_stage.sourceDB = fact_stage.sourceDB
    and player_stage.player_id = fact_stage.player_id
  )
);


-- Update the Teams stage (gets the players current team)
update fact_stage set team_sk=(
  select team_stage.team_sk from team_stage where (
    team_stage.sourceDB = fact_stage.sourceDB
    and team_stage.team_name = fact_stage.team_a_id
  )
);

-- Update the Opposition stage (gets the players oppositon teams)
update fact_stage set opponent_sk=(
  select team_stage.team_sk from team_stage where (
    team_stage.sourceDB = fact_stage.sourceDB
    and team_stage.team_name = fact_stage.team_b_id
  )
);

-- Update the Stadiums stage
update fact_stage set stadium_sk=(
  select stadium_stage.stadium_sk from stadium_stage
  join team_stage on stadium_stage.team_id = team_stage.team_id
  where (
    stadium_stage.sourceDB = fact_stage.sourceDB
    and stadium_stage.team_id = team_stage.team_id
    and team_stage.team_name = fact_stage.team_a_id
  )
);

-- Update the time stage
update fact_stage set date_sk=(
  select time_stage.date_sk from time_stage where (
    time_stage.sourceDB = fact_stage.sourceDB
    and time_stage.team_a = fact_stage.team_a_id
    and time_stage.team_b = fact_stage.team_b_id
    and time_stage.m_date = fact_stage.m_date
  )
);

-- insert into the Fact_Stats table
insert into Fact_Stats (date_sk, player_sk, team_sk, opponent_sk, stadium_sk, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko) select date_sk, player_sk, team_sk, opponent_sk, stadium_sk, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko from fact_stage;



-- Undergo the second etl below

-- Load the second set of data
load data local infile '~/ETL2.csv'
into table HolderTable
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;


-- Insert into Player
insert into Player (Player_ID, TeamID, PL_name, PL_surname)
select distinct player_id, team_a_id, player_name, player_surname
from HolderTable where player_id!='0' and not exists (
  select * from Player where HolderTable.player_id=Player.Player_ID
);

-- Insert into Matches
insert into Matches (Team_A, Team_B, M_date)
select distinct team_a_name, team_b_name, m_date
from HolderTable where team_a_name!='' and not exists (
  select * from Matches where
  HolderTable.team_a_name = Matches.Team_A and
  HolderTable.team_b_name = Matches.Team_B and
  HolderTable.m_date = Matches.M_date
);

-- Insert into Player_stats
insert into Player_stats (Team_A_ID, Team_B_ID, Player_ID, M_date, MinPlayed, Goals, Shot_on, Shot_off, Penalty, Pass_OK, Pass_KO)
select team_a_name, team_b_name, player_id, m_date, minutes_played, goal, shots_on_target, shots_off_target, penalties, pass_success, pass_fail
from HolderTable where player_id!='0' and team_a_name!='' and not exists (
  select * from Player_stats where
  HolderTable.team_a_name = Player_stats.Team_A_ID and
  HolderTable.team_b_name = Player_stats.Team_B_ID and
  HolderTable.m_date = Player_stats.M_date and
  HolderTable.player_id = Player_stats.Player_ID
);


-- Insert the data into the staging table checking to make sure the data doesnt already exist

-- Insert the data into the player_stage table
insert into player_stage (sourceDB, player_id, player_name, player_surname) select 1, player_id, PL_name, PL_surname from Player
where not exists (
  select * from player_stage where
  Player.Player_ID=player_stage.player_id
);


-- Insert the data into the DimPlayer table
insert into DimPlayer (player_sk, player_name, player_surname)
select player_sk, player_name, player_surname from player_stage where not exists (
  select * from DimPlayer where
  player_stage.player_sk=DimPlayer.player_sk
);

-- Insert the data into the team_stage table
insert into team_stage (sourceDB, team_id, team_name, year_of_foundation) select 1, TeamID, Team_name, YearOfFound from Teams where not exists (
  select * from team_stage where
  Teams.TeamID=team_stage.team_id
);

-- Insert the data into the DimTeam table
insert into DimTeam (team_sk, team_name, year_of_foundation) select team_sk, team_name, year_of_foundation from team_stage where not exists(
  select * from DimTeam where
  team_stage.team_sk=DimTeam.team_sk
);

-- insert the data into the stadium_stage table
insert into stadium_stage (stadiumID, sourceDB, st_name, city, capacity, team_id) select StadiumID, 1, St_name, City, Capacity, TeamID from Stadiums where not exists (
  select * from stadium_stage where
  Stadiums.StadiumID=stadium_stage.stadiumID
);

-- insert the data into the DimStadium table
insert into DimStadium (stadium_sk, stadium_name, stadium_city, capacity) select stadium_sk, stadiumID, city, capacity from stadium_stage where not exists (
  select * from DimStadium where
  stadium_stage.stadium_sk=DimStadium.stadium_sk
);

-- insert data into the staging table
insert into time_stage (sourceDB, team_a, team_b, m_date, year, month, day) select 1, Team_A, Team_B, M_date, extract(year from m_date), extract(month from m_date), extract(day from m_date) from Matches where not exists (
  select * from time_stage where
  Matches.Team_A=time_stage.team_a and
  Matches.Team_B=time_stage.team_b and
  Matches.M_date=time_stage.m_date
);

-- insert data into the Dim Table
insert into DimTime (date_sk, year, month, day) select date_sk, year, month, day from time_stage where not exists (
  select * from DimTime where
  time_stage.date_sk=DimTime.date_sk
);

-- insert into the fact_stage table
insert into fact_stage (sourceDB, team_a_id, team_b_id, player_ID, m_date, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko) select 1, Team_A_ID, Team_B_ID, Player_ID, M_date, MinPlayed, Goals, Shot_on, Shot_off, Penalty, Pass_OK, Pass_KO from Player_stats where not exists (
  select * from fact_stage where
  Player_stats.Team_A_ID=fact_stage.team_a_id and
  Player_stats.Team_B_ID=fact_stage.team_b_id and
  Player_stats.M_date=fact_stage.m_date and
  Player_stats.Player_ID=fact_stage.player_ID
);


-- Update the surrogate keys within the fact table

-- Update the fact_stage
update fact_stage set stadium_id=(
  select stadium_stage.stadiumID from stadium_stage
  join team_stage on stadium_stage.team_id = team_stage.team_id
  where (
    stadium_stage.sourceDB = fact_stage.sourceDB
    and stadium_stage.team_id = team_stage.team_id
    and team_stage.team_name = fact_stage.team_a_id
  )
);

-- Update the player stage
update fact_stage set player_sk=(
  select player_stage.player_sk from player_stage where (
    player_stage.sourceDB = fact_stage.sourceDB
    and player_stage.player_id = fact_stage.player_id
  )
);

-- Update the Teams stage (gets the players current team)
update fact_stage set team_sk=(
  select team_stage.team_sk from team_stage where (
    team_stage.sourceDB = fact_stage.sourceDB
    and team_stage.team_name = fact_stage.team_a_id
  )
);

-- Update the Opposition stage (gets the players oppositon teams)
update fact_stage set opponent_sk=(
  select team_stage.team_sk from team_stage where (
    team_stage.sourceDB = fact_stage.sourceDB
    and team_stage.team_name = fact_stage.team_b_id
  )
);

-- Update the Stadiums stage
update fact_stage set stadium_sk=(
  select stadium_stage.stadium_sk from stadium_stage
  join team_stage on stadium_stage.team_id = team_stage.team_id
  where (
    stadium_stage.sourceDB = fact_stage.sourceDB
    and stadium_stage.team_id = team_stage.team_id
    and team_stage.team_name = fact_stage.team_a_id
  )
);

-- Update the time stage
update fact_stage set date_sk=(
  select time_stage.date_sk from time_stage where (
    time_stage.sourceDB = fact_stage.sourceDB
    and time_stage.team_a = fact_stage.team_a_id
    and time_stage.team_b = fact_stage.team_b_id
    and time_stage.m_date = fact_stage.m_date
  )
);

-- insert into the Fact_Stats table
insert into Fact_Stats (date_sk, player_sk, team_sk, opponent_sk, stadium_sk, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko) select date_sk, player_sk, team_sk, opponent_sk, stadium_sk, min_played, goals, shot_on, shot_off, penalty, pass_ok, pass_ko from fact_stage;


-- Second etl completed

-- Query the database

-- Get a players top 5 performances by a player measured by number of goals scored
-- and display where they where and who the opponent was
-- The example below shows the stats for the player with first name "Clint"
select player_name, stadium_name, team_name, goals from Fact_Stats
join DimStadium on Fact_Stats.stadium_sk=DimStadium.stadium_sk
join DimPlayer on Fact_Stats.player_sk=DimPlayer.player_sk
join DimTeam on Fact_stats.opponent_sk=DimTeam.team_sk
where player_name="Clint"
order by goals desc
limit 5;

-- Get player with the highest pass rate on a team for a given year
-- Example below shows the results for the Manchester United team
select distinct player_name, player_surname, team_name, pass_ok, year from Fact_Stats
join DimTeam on Fact_Stats.team_sk=DimTeam.team_sk
join DimPlayer on Fact_Stats.player_sk=DimPLayer.player_sk
join DimTime on Fact_Stats.date_sk=DimTime.date_sk
where team_name="Manchester United" and year="2012"
order by pass_ok desc;


-- Everything above tested and passed
