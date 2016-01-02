-- Load the second set of data
load data local infile '~/ETL2.csv'
into table HolderTable
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;


-- The second load should have happened at this point

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
-- Tested and passed to here
