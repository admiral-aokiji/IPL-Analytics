select * from matches;
select * from deliveries;
select count(*) from deliveries;
select * from teams;
select * from point_table;
select * from venues; 
select * from match_over_scorecards; 


-- Individual season batting stats
-- select batting_team, season, batsman, count(ball), sum(batsman_runs), count(DISTINCT match_id) from deliveries join matches using (match_id) group by season,batting_team,batsman order by sum(batsman_runs) desc; (use rollup for team stint totals)

-- overall batting stats
-- select batsman, count(ball) as balls, sum(batsman_runs) as runs, batting_team from deliveries group by batsman order by balls desc;

-- ball possible outcomes grouping (improve and consider all cases)
-- select batsman_runs, extra_runs, count(*) from deliveries where player_dismissed is null GROUP BY batsman_runs union select dismissal_kind,total_runs, count(*) from deliveries where player_dismissed is not null group by dismissal_kind, total_runs;
-- same can be repeated but split according to 1. innings, 2. group stage and playoffs, 3. teams, 4. venues, 5. by nationality of batsmen

-- date_format(date,'%m-%d') for month-date, check for day of week also 

-- joining 2 tables without JOIN but with sub-query and where clause
-- select match_id, season, date, m.venue_id, batting_team1, batting_team2, team1_match_type, team2_match_type, t.team_name as team1, (select team_name from teams as t2 where t2.team_short_name = m.batting_team2 and t2.team_id = t2.parent_team_id) as team2 from matches as m, teams as t where t.team_short_name = m.batting_team1 and t.team_id = t.parent_team_id; 
-- joining 2 tables with JOIN to update match_types for the 129 cases where home_stadium1 does not do the trick
-- select * from matches join venues as v using (venue_id) left join teams as t on t.home_stadium2 = v.venue_id and t.team_id = t.parent_team_id where team1_match_type = 'neutral'; 

-- create temporary table matches2 select * from matches join venues using (venue_id) order by season;

-- generating innings totals for each match using common table expressions
-- with inning1 as 
-- 	(select match_id, sum(total_runs) as team1_total from deliveries where match_id <= 60 and inning =1 GROUP BY match_id)
-- select match_id,team1_total, sum(total_runs) as team2_total, if (sum(total_runs)>=team1_total,'win by wickets', team1_total- sum(total_runs)) as win_margin from deliveries join inning1 using (match_id) where match_id < 60 and inning =2 GROUP BY match_id; 

-- to check whether batsman runs are always getting added with extra_runs for season > 2017 for wide_runs, bye_runs, legbye_runs, noball_runs
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, wide_runs, batsman_runs, extra_runs, total_runs, wide_runs = batsman_runs, total_runs = (batsman_runs + extra_runs) from deliveries where wide_runs != 0 and match_id >800;
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, bye_runs, batsman_runs, extra_runs, total_runs, bye_runs = batsman_runs, total_runs = (batsman_runs + extra_runs) from deliveries where bye_runs != 0 and match_id >800;
-- select ball_id, match_id, inning, batting_team, bowling_team,`over`, ball, noball_runs, batsman_runs, extra_runs, total_runs, batsman_runs - noball_runs, total_runs = (batsman_runs + extra_runs) from deliveries where noball_runs != 0 and match_id >800;

start transaction;
rollback;
commit;

-- select match_id, season, result_type, batting_team1, batting_team2, team1_runs, team1_wickets, team2_runs, team2_wickets,win_by_wickets, if (team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs) as win_margin,win_by_runs, case when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_runs then 1 when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_wickets then -1  else 0 end as test from matches where (case when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_runs then 1 when (if(team2_runs>=team1_runs,10 - team2_wickets, team1_runs- team2_runs)) = win_by_wickets then -1  else 0 end)=0 and result_type not in ('tie','no result', 'DL applied') order by date;

-- select match_id, inning, max(`over`), floor(count(ball)/6) + round((count(ball)%6)/10,1) from deliveries where wide_runs=0 and noball_runs=0 group by match_id, inning;

-- select * from deliveries where dismissal_kind in ('caught', 'run out') and fielder is null;

select match_id, inning, batting_team, batsman, sum(batsman_runs), max(ball_id) from deliveries group by match_id, inning, batsman;
select match_id, inning, batting_team, batsman, count(ball) from deliveries where wide_runs = 0 and noball_runs = 0 group by match_id, inning, batsman;
select match_id, inning, batting_team, `over`, count(ball) from deliveries where player_dismissed is not null group by match_id, inning, `over` having count(ball) > 4;








create temporary table away_stats;
select season, count(case when winner != 'KKR' then null else 1 end) wins, 
	count(case when result_type != 'no result' then null else 1 end) no_results, 
    count(*) - count(case when winner != 'KKR' then null else 1 end) - count(case when result_type != 'no result' then null else 1 end) as losses, 
    sum(case when team1_match_type = 'away' then team1_runs when team2_match_type = 'away' then team2_runs else null end) away_runs, 
    sum(case when team1_match_type = 'away' then team1_wickets when team2_match_type = 'away' then team2_wickets else null end) away_wickets, 
    sum(case when team1_match_type = 'away' then floor(team1_overs) when team2_match_type = 'away' then team2_overs else null end) away_overs -- correct sum of balls
    from matches where (batting_team1 = 'KKR' and team1_match_type = 'away') or (batting_team2 = 'KKR' and team2_match_type = 'away') and season != 2014 group by season;

create temporary table home_stats;    
select season, count(case when winner != 'KKR' then null else 1 end) wins, 
	count(case when result_type != 'no result' then null else 1 end) no_results, 
    count(*) - count(case when winner != 'KKR' then null else 1 end) - count(case when result_type != 'no result' then null else 1 end) as losses, 
    sum(case when team1_match_type = 'home' then team1_runs when team2_match_type = 'home' then team2_runs else null end) away_runs, 
    sum(case when team1_match_type = 'home' then team1_wickets when team2_match_type = 'home' then team2_wickets else null end) away_wickets, 
    sum(case when team1_match_type = 'home' then floor(team1_overs) when team2_match_type = 'home' then team2_overs else null end) away_overs -- correct sum of balls
    from matches where (batting_team1 = 'KKR' and team1_match_type = 'home') or (batting_team2 = 'KKR' and team2_match_type = 'home') and season != 2014 group by season;

-- 2009 and 2014 (doubtful)
select season, count(case when winner != 'KKR' then null else 1 end) wins, 
	count(case when result_type != 'no result' then null else 1 end) no_results, 
    count(*) - count(case when winner != 'KKR' then null else 1 end) - count(case when result_type != 'no result' then null else 1 end) as losses,
    sum(case when batting_team1 = 'KKR' then team1_runs when batting_team2 = 'KKR' then team2_runs else null end) runs, 
    sum(case when batting_team1 = 'KKR' then team1_wickets when batting_team2 = 'KKR' then team2_wickets else null end) wickets, 
    sum(case when batting_team1 = 'KKR' then floor(team1_overs) when batting_team2 = 'KKR' then team2_overs else null end) overs, -- correct sum of balls
    sum(case when batting_team1 != 'KKR' then team1_runs when batting_team2 != 'KKR' then team2_runs else null end) away_runs, 
    sum(case when batting_team1 != 'KKR' then team1_wickets when batting_team2 != 'KKR' then team2_wickets else null end) away_wickets, 
    sum(case when batting_team1 != 'KKR' then team1_oversh when batting_team2 != 'KKR' then team2_overs else null end) away_overs, -- correct sum of balls
    count(case when toss_winner = 'KKR' then 1 else null end) tosses_won
    from matches where (batting_team1 = 'KKR' or batting_team2 = 'KKR') and season = 2009 group by season;




select season, batting_team1, sum(team1_runs), sum(team1_overs), count(*) from matches where team1_match_type not in ('final','semifinals', 'eliminator','3rd place') group by season, batting_team1;












