create table DimPlayer (
  player_sk int not null auto_increment,
  player_name varchar(255),
  player_surname varchar(255),
  primary key (player_sk)
);

create table DimTeam (
  team_sk int,
  team_name varchar(255),
  year_of_foundation int,
  primary key (team_sk)
);

create table DimTime (
  date_sk int,
  year int,
  month int,
  day int,
  primary key (date_sk)
);

create table DimStadium (
  stadium_sk int,
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
