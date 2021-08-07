select * from matches ;
select * from deliveries;
select * from deliveries2;
select * from teams;
select * from venues; 
select * from match_over_scorecards; 
select * from match_bowler_scorecards; 
select * from match_batsman_scorecards2; 
select * from match_batsman_scorecards; 
select * from points_table order by season, points desc, net_run_rate desc;
select * from team_season_matches;

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

-- 20 matches in UAE in 2014 and 3 other neutral matches = 23 neutral matches 
select * from matches where team1_match_type = team2_match_type and year(date) not in (2009,2020) and team1_match_type = 'neutral';

-- to check whether batsman runs are always getting added with extra_runs for season > 2017 for wide_runs, bye_runs, legbye_runs, noball_runs
select ball_id, match_id, inning, `over`, ball, batsman_runs, extra_runs, total_runs, extras_type, extra_runs = total_runs from deliveries where extra_runs != 0 and extras_type like 'wides%' and match_id >600;

-- checking whether win_by_runs/wickets columns matches the winning margin generated using the calculated innings score
select match_id, year(date), result_type, batting_team1, batting_team2, team1_runs, team1_wickets, team2_runs, team2_wickets, win_type, win_margin, if (team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs) as win_margin_calc, (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_margin as test from matches where result_type not in ('tie','no result', 'DL applied') order by date;

-- after python script, check whether max(ball_id)'s teamScore == team1_runs

-- 104 cases of innings starting from wide/no-ball (TILL 2019). if any instances of wrong formatting by python script, then this result will not match
-- select * from deliveries where striker_runs = 0 and striker_balls = 0 and non_striker_balls = 0 and non_striker_runs = 0 and team_overs = 0;

-- run and extras per over test
select match_id, inning, over_no, runs, (singles + 2*doubles + 3*triples + 4*fours + 6*sixes + 5*fives + extras) as run_c, runs = (singles + 2*doubles + 3*triples + 4*fours + 6*sixes  + 5*fives + extras) as run_test, extras, (wide_runs + noball_runs + legbye_runs + bye_runs + penalty_runs) as extra_c, extras = (wide_runs + noball_runs + legbye_runs + bye_runs + penalty_runs) as extra_test from match_over_scorecards group by match_id, inning, over_no HAVING extra_test != 1 or run_test != 1; 

start transaction;
rollback;
commit;

-- update deliveries set team_runs = total_runs, team_overs = if(noball_runs = 0 and (extras_type is null or extras_type in ('byes','legbyes')),0.1,0.0) where `over` = 1 and ball = 1;
-- rows between 1st ball of inning and current row --> generating team_runs (sum of total_runs) and team_overs(count legal balls and convert to overs using %6 and floor+/6)
-- update deliveries set team_runs = total_runs + lag(team_runs,1) over (PARTITION BY match_id) where `over` != 1 and ball != 1;

-- innings with 2 batsmen not out in the end
-- SELECT match_id, inning, count(batsman) not_out from match_batsman_scorecards where dismissal_type is null group by match_id, inning having not_out>1)
-- update end_partner_runs for these cases

-- check if deliveries team_overs > 20 (after python)
select * from deliveries2 where team_overs > 20;

-- incomplete overs (allow only max)
-- select * from match_bowler_scorecards WHERE balls%6 != 0 group by match_id, inning; 

select * from match_bowler_scorecards order by maidens + near_maidens desc; 

SELECT match_id, inning, count(batsman) from match_batsman_scorecards group by match_id, inning HAVING count(batsman) != 11 ;