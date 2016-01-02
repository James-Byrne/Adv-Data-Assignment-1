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
insert into DimStadium (stadium_sk, stadium_name, stadium_city, capacity) select stadium_sk, stadiumID, city, capacity from stadium_stage;



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

-- insert into fact_stage (stadium_id) select stadiumID from stadium_stage join
--   team_stage on stadium_stage.team_id = team_stage.team_id
--   where fact_stage.team_a_id = team_stage.team_name;

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
