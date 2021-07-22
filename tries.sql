select * from matches;
select * from deliveries;
select * from teams;
select * from venues; 
select * from match_over_scorecards; 
select * from match_bowler_scorecards; 
select * from match_batsman_scorecards; 
select * from points_table;

-- ball possible outcomes grouping (improve and consider all cases)
-- legal balls + no wickets
select batsman_runs, extra_runs, legbye_runs, bye_runs,penalty_runs, count(*) from deliveries where player_dismissed is null and wide_runs = 0 and noball_runs = 0 GROUP BY batsman_runs,legbye_runs, bye_runs, penalty_runs order by batsman_runs, extra_runs, legbye_runs;
-- legal balls + wickets
select batsman_runs, extra_runs, legbye_runs, bye_runs, count(*), dismissal_kind from deliveries where player_dismissed is not null and wide_runs = 0 and noball_runs = 0 GROUP BY batsman_runs,legbye_runs, bye_runs, dismissal_kind order by batsman_runs, extra_runs, legbye_runs; 
-- wide balls + no wickets
select wide_runs, count(*) from deliveries where player_dismissed is null and wide_runs != 0 GROUP BY wide_runs order by wide_runs;
-- wide balls + wickets
select wide_runs, count(*), dismissal_kind from deliveries where player_dismissed is not null and wide_runs != 0 GROUP BY wide_runs,dismissal_kind order by wide_runs;
-- no balls + wickets
select noball_runs, batsman_runs, count(*), dismissal_kind from deliveries where player_dismissed is not null and noball_runs != 0 GROUP BY noball_runs,batsman_runs,dismissal_kind order by extra_runs,batsman_runs;
-- no balls + no wickets -- ERROR -- 16 cases of noball_runs > 1, all for seasons < 2018 
select noball_runs, batsman_runs, count(*) from deliveries where player_dismissed is null and noball_runs != 0 GROUP BY noball_runs,batsman_runs order by extra_runs, batsman_runs;
-- Can be further split according to 1. innings, 2. group stage and playoffs, 3. teams, 4. venues, 5. by nationality of batsmen 

-- date_format(date,'%m-%d') for month-date, check for day of week also 
-- joining 2 tables without JOIN but with sub-query and where clause
-- select match_id, season, date, m.venue_id, batting_team1, batting_team2, team1_match_type, team2_match_type, t.team_name as team1, (select team_name from teams as t2 where t2.team_short_name = m.batting_team2 and t2.team_id = t2.parent_team_id) as team2 from matches as m, teams as t where t.team_short_name = m.batting_team1 and t.team_id = t.parent_team_id; 
-- joining 2 tables with JOIN to update match_types for the 129 cases where home_stadium1 does not do the trick
-- select * from matches join venues as v using (venue_id) left join teams as t on t.home_stadium2 = v.venue_id and t.team_id = t.parent_team_id where team1_match_type = 'neutral'; 

-- generating innings totals for each match using common table expressions
-- with inning1 as 
-- 	(select match_id, sum(total_runs) as team1_total from deliveries where match_id <= 60 and inning =1 GROUP BY match_id)
-- select match_id,team1_total, sum(total_runs) as team2_total, if (sum(total_runs)>=team1_total,'win by wickets', team1_total- sum(total_runs)) as win_margin from deliveries join inning1 using (match_id) where match_id < 60 and inning =2 GROUP BY match_id; 

-- check whether home away have been updated successfully
-- select * from matches where team1_match_type = team2_match_type and team1_match_type not in ('final','3rd place', 'semifinals', 'eliminator') and season != 2009;

-- to check whether batsman runs are always getting added with extra_runs for season > 2017 for wide_runs, bye_runs, legbye_runs, noball_runs
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, wide_runs, batsman_runs, extra_runs, total_runs, wide_runs = batsman_runs, total_runs = (batsman_runs + extra_runs) from deliveries where wide_runs != 0 and match_id >800;
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, bye_runs, batsman_runs, extra_runs, total_runs, bye_runs = batsman_runs, total_runs = (batsman_runs + extra_runs) from deliveries where bye_runs != 0 and match_id >800;
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, noball_runs, batsman_runs, extra_runs, total_runs, batsman_runs - noball_runs, total_runs = (batsman_runs + extra_runs) from deliveries where noball_runs != 0 and match_id >800;

-- checking whether win_by_runs/wickets columns matches the winning margin generated using the calculated innings score
-- select match_id, season, result_type, batting_team1, batting_team2, team1_runs, team1_wickets, team2_runs, team2_wickets,win_by_wickets, if (team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs) as win_margin,win_by_runs, case when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_runs then 1 when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_wickets then -1  else 0 end as test from matches where (case when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_runs then 1 when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_wickets then -1  else 0 end)=0 and result_type not in ('tie','no result', 'DL applied') order by date;

-- select * from deliveries where dismissal_kind in ('caught', 'run out') and fielder is null;

-- 104 cases of innings starting from wide/no-ball. if any instances of wrong formatting by python script, then this result will not match
-- select * from deliveries where striker_runs = 0 and striker_balls = 0 and non_striker_balls = 0 and non_striker_runs = 0 and team_overs = 0;

-- innings with 2 batsmen not out in the end
-- SELECT match_id, inning, count(batsman) not_out from match_batsman_scorecards where dismissal_type is null group by match_id, inning having not_out>1)
-- update end_partner_runs for these cases

start transaction;
rollback;
commit;




 