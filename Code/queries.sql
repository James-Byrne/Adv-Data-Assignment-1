-- Get a players top 5 performances measured by number of goals scored
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
-- Examplle below shows the results for the Manchester United team
select distinct player_name, player_surname, team_name, pass_ok, year from Fact_Stats
join DimTeam on Fact_Stats.team_sk=DimTeam.team_sk
join DimPlayer on Fact_Stats.player_sk=DimPLayer.player_sk
join DimTime on Fact_Stats.date_sk=DimTime.date_sk
where team_name="Manchester United" and year="2012"
order by pass_ok desc;
