select * from matches;
select * from deliveries;
select count(*) from deliveries;
select * from teams;
select * from point_table;
select * from venues; 

-- Individual season batting stats
-- select batting_team, season, batsman, count(ball), sum(batsman_runs), count(DISTINCT match_id) from deliveries join matches using (match_id) group by season,batting_team,batsman order by sum(batsman_runs) desc; (use rollup for team stint totals)

-- overall batting stats
-- select batsman, count(ball) as balls, sum(batsman_runs) as runs, batting_team from deliveries group by batsman order by balls desc;

-- ball possible outcomes grouping (improve and consider all cases)
select batsman_runs, count(*) from deliveries where extra_runs = 0 and player_dismissed is null GROUP BY batsman_runs union select 'wickets', count(*) from deliveries where player_dismissed is not null;
-- same can be repeated but split according to 1. innings, 2. group stage and playoffs, 3. teams, 4. venues, 5. by nationality of batsmen

-- date_format(date,'%m-%d') for month-date, check for day of week also 

-- joining 2 tables without JOIN but with sub-query and where clause
-- select match_id, season, date, m.venue_id, batting_team1, batting_team2, team1_match_type, team2_match_type, t.team_name as team1, (select team_name from teams as t2 where t2.team_short_name = m.batting_team2 and t2.team_id = t2.parent_team_id) as team2 from matches as m, teams as t where t.team_short_name = m.batting_team1 and t.team_id = t.parent_team_id; 
-- joining 2 tables with JOIN to update match_types for the 129 cases where home_stadium1 does not do the trick
-- select * from matches join venues as v using (venue_id) left join teams as t on t.home_stadium2 = v.venue_id and t.team_id = t.parent_team_id where team1_match_type = 'neutral'; 

-- create temporary table matches2 select * from matches join venues using (venue_id) order by season;

start transaction;
rollback;
commit;

-- wide_runs, bye_runs, legbye_runs, noball_runs, penalty_runs, batsman_runs, extra_runs, total_runs

-- generating innings totals for each match
with inning1 as 
	(select match_id, sum(total_runs) as team1_total from deliveries where match_id <= 60 and inning =1 GROUP BY match_id)
select match_id,team1_total, sum(total_runs) as team2_total, if (sum(total_runs)>=team1_total,'win by wickets', team1_total- sum(total_runs)) as win_margin from deliveries join inning1 using (match_id) where match_id < 60 and inning =2 GROUP BY match_id; 

-- , concat(max(`over`) - 1, select max(ball) where `over` = max(`over`))
