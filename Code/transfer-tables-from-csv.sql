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
