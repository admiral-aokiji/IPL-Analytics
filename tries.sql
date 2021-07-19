select * from matches;
select * from deliveries;
select * from teams;
select * from venues; 
select * from match_over_scorecards; 
select * from match_bowler_scorecards; 
select * from points_table;

-- ball possible outcomes grouping (improve and consider all cases)
select batsman_runs, extra_runs, count(*) from deliveries where player_dismissed is null GROUP BY batsman_runs union select dismissal_kind,total_runs, count(*) from deliveries where player_dismissed is not null group by dismissal_kind, total_runs;
-- same can be repeated but split according to 1. innings, 2. group stage and playoffs, 3. teams, 4. venues, 5. by nationality of batsmen

-- date_format(date,'%m-%d') for month-date, check for day of week also 
-- joining 2 tables without JOIN but with sub-query and where clause
-- select match_id, season, date, m.venue_id, batting_team1, batting_team2, team1_match_type, team2_match_type, t.team_name as team1, (select team_name from teams as t2 where t2.team_short_name = m.batting_team2 and t2.team_id = t2.parent_team_id) as team2 from matches as m, teams as t where t.team_short_name = m.batting_team1 and t.team_id = t.parent_team_id; 
-- joining 2 tables with JOIN to update match_types for the 129 cases where home_stadium1 does not do the trick
-- select * from matches join venues as v using (venue_id) left join teams as t on t.home_stadium2 = v.venue_id and t.team_id = t.parent_team_id where team1_match_type = 'neutral'; 

-- generating innings totals for each match using common table expressions
-- with inning1 as 
-- 	(select match_id, sum(total_runs) as team1_total from deliveries where match_id <= 60 and inning =1 GROUP BY match_id)
-- select match_id,team1_total, sum(total_runs) as team2_total, if (sum(total_runs)>=team1_total,'win by wickets', team1_total- sum(total_runs)) as win_margin from deliveries join inning1 using (match_id) where match_id < 60 and inning =2 GROUP BY match_id; 

-- to check whether batsman runs are always getting added with extra_runs for season > 2017 for wide_runs, bye_runs, legbye_runs, noball_runs
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, wide_runs, batsman_runs, extra_runs, total_runs, wide_runs = batsman_runs, total_runs = (batsman_runs + extra_runs) from deliveries where wide_runs != 0 and match_id >800;
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, bye_runs, batsman_runs, extra_runs, total_runs, bye_runs = batsman_runs, total_runs = (batsman_runs + extra_runs) from deliveries where bye_runs != 0 and match_id >800;
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, noball_runs, batsman_runs, extra_runs, total_runs, batsman_runs - noball_runs, total_runs = (batsman_runs + extra_runs) from deliveries where noball_runs != 0 and match_id >800;

-- checking whether win_by_runs/wickets columns matches the winning margin generated using the calculated innings score
-- select match_id, season, result_type, batting_team1, batting_team2, team1_runs, team1_wickets, team2_runs, team2_wickets,win_by_wickets, if (team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs) as win_margin,win_by_runs, case when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_runs then 1 when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_wickets then -1  else 0 end as test from matches where (case when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_runs then 1 when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_wickets then -1  else 0 end)=0 and result_type not in ('tie','no result', 'DL applied') order by date;

-- select * from deliveries where dismissal_kind in ('caught', 'run out') and fielder is null;

-- 104 cases of innings starting from wide/no-ball. if any instances of wrong formatting by python script, then this result will not match
-- select * from deliveries where striker_runs = 0 and striker_balls = 0 and non_striker_balls = 0 and non_striker_runs = 0 and team_overs = 0;

start transaction;
rollback;
commit;


-- ROW_NUMBER() OVER (PARTITION BY match_id, inning ORDER BY min(team_overs) ) position -- here min(team_overs) needs to be replaced by first ball on pitch

-- sum of all singles, doubles ... sixes wont give balls as legbyes, byes will also be added for that 

-- drop table inning_stats;
select * from inning_stats;
select * from dismissal_stats;






-- DROP PROCEDURE if exists getBatsmanStats;
-- DELIMITER $$
-- CREATE PROCEDURE getOverStats (IN  startOver decimal(3,1), IN  endOver decimal(3,1))
-- BEGIN 
-- 	drop table if exists non_strike_min;
-- 	drop table if exists inning_stats;
-- 	drop table if exists dismissal_stats;
    
    -- create TEMPORARY table inning_stats 
	select d.match_id, d.inning, d.batsman, sum(batsman_runs) runs, count(case when wide_runs = 0 and noball_runs = 0 then 1 else null end) balls, count(case when total_runs = 0 then 1 else null end) dots, count(case when batsman_runs = 1 then 1 else null end) singles,count(case when batsman_runs = 2 then 1 else null end) doubles, count(case when batsman_runs = 3 then 1 else null end) triples, count(case when batsman_runs = 4 then 1 else null end) fours, count(case when batsman_runs = 6 then 1 else null end) sixes, min(d.team_overs) teamOversArrival from deliveries as d group by match_id,inning, batsman;
    
    create TEMPORARY table non_strike_min
    select match_id, inning, non_striker ,min(team_overs) from deliveries GROUP BY match_id, inning, non_striker;
    
    -- create TEMPORARY table dismissal_stats
	select match_id, inning, batsman, dismissal_kind, bowler, fielder, player_dismissed, striker_runs, striker_balls, non_striker_runs, non_striker_balls, team_overs from deliveries where player_dismissed is not null;
    
    -- batsman that got out without ever facing a ball/ the innings ended
    SELECT * from inning_stats i right join non_strike_min n on n.match_id = i.match_id and n.inning = i.inning and n.non_striker = i.batsman where i.batsman is null order by balls;
    -- batsman that got out without the strike getting rotated (duck in the same over)
    SELECT * from inning_stats i left join non_strike_min n on n.match_id = i.match_id and n.inning = i.inning and n.non_striker = i.batsman where n.non_striker is null order by balls;  

-- END$$
-- DELIMITER ;


-- DROP PROCEDURE getBatsmanStats;
