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
