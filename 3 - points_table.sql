-- for seasons where no of teams<10 and != 2009,2014
drop table if exists points_table;
CREATE TABLE IF NOT EXISTS points_table (
  entry_id int unsigned NOT NULL AUTO_INCREMENT,
  season mediumint NOT NULL,
  team varchar(45) NOT NULL,
  home_wins smallint DEFAULT 0,
  home_losses smallint DEFAULT 0,
  home_nr smallint DEFAULT 0,
  away_wins smallint DEFAULT 0,
  away_losses smallint DEFAULT 0,
  away_nr smallint DEFAULT 0,
  for_runs mediumint DEFAULT 0,
  for_wickets mediumint DEFAULT 0,
  for_overs decimal(5,1) DEFAULT 0.0,
  away_runs mediumint DEFAULT 0,
  away_wickets mediumint DEFAULT 0,
  away_overs decimal(5,1) DEFAULT 0.0,
  net_run_rate decimal(5,4) DEFAULT 0.0000,
  tosses_won smallint DEFAULT 0,
  longest_win_streak smallint DEFAULT 0,
  longest_loss_streak smallint DEFAULT 0,
  potm_awards smallint DEFAULT 0,
  PRIMARY KEY (entry_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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





-- create temporary table away_stats;
-- select season, count(case when winner != 'KKR' then null else 1 end) wins, 
-- 	count(case when result_type != 'no result' then null else 1 end) no_results, 
--     count(*) - count(case when winner != 'KKR' then null else 1 end) - count(case when result_type != 'no result' then null else 1 end) as losses, 
--     sum(case when team1_match_type = 'away' then team1_runs when team2_match_type = 'away' then team2_runs else null end) away_runs, 
--     sum(case when team1_match_type = 'away' then team1_wickets when team2_match_type = 'away' then team2_wickets else null end) away_wickets, 
--     sum(case when team1_match_type = 'away' then floor(team1_overs) when team2_match_type = 'away' then team2_overs else null end) away_overs -- correct sum of balls
--     from matches where (batting_team1 = 'KKR' and team1_match_type = 'away') or (batting_team2 = 'KKR' and team2_match_type = 'away') and season != 2014 group by season;

-- create temporary table home_stats;    
-- select season, count(case when winner != 'KKR' then null else 1 end) wins, 
-- 	count(case when result_type != 'no result' then null else 1 end) no_results, 
--     count(*) - count(case when winner != 'KKR' then null else 1 end) - count(case when result_type != 'no result' then null else 1 end) as losses, 
--     sum(case when team1_match_type = 'home' then team1_runs when team2_match_type = 'home' then team2_runs else null end) away_runs, 
--     sum(case when team1_match_type = 'home' then team1_wickets when team2_match_type = 'home' then team2_wickets else null end) away_wickets, 
--     sum(case when team1_match_type = 'home' then floor(team1_overs) when team2_match_type = 'home' then team2_overs else null end) away_overs -- correct sum of balls
--     from matches where (batting_team1 = 'KKR' and team1_match_type = 'home') or (batting_team2 = 'KKR' and team2_match_type = 'home') and season != 2014 group by season;

-- 2009 and 2014 (doubtful)
-- select season, count(case when winner != 'KKR' then null else 1 end) wins, 
-- 	count(case when result_type != 'no result' then null else 1 end) no_results, 
--     count(*) - count(case when winner != 'KKR' then null else 1 end) - count(case when result_type != 'no result' then null else 1 end) as losses,
--     sum(case when batting_team1 = 'KKR' then team1_runs when batting_team2 = 'KKR' then team2_runs else null end) runs, 
--     sum(case when batting_team1 = 'KKR' then team1_wickets when batting_team2 = 'KKR' then team2_wickets else null end) wickets, 
--     sum(case when batting_team1 = 'KKR' then floor(team1_overs) when batting_team2 = 'KKR' then team2_overs else null end) overs, -- correct sum of balls
--     sum(case when batting_team1 != 'KKR' then team1_runs when batting_team2 != 'KKR' then team2_runs else null end) away_runs, 
--     sum(case when batting_team1 != 'KKR' then team1_wickets when batting_team2 != 'KKR' then team2_wickets else null end) away_wickets, 
--     sum(case when batting_team1 != 'KKR' then team1_oversh when batting_team2 != 'KKR' then team2_overs else null end) away_overs, -- correct sum of balls
--     count(case when toss_winner = 'KKR' then 1 else null end) tosses_won
--     from matches where (batting_team1 = 'KKR' or batting_team2 = 'KKR') and season = 2009 group by season;

-- select season, batting_team1, sum(team1_runs), sum(team1_overs), count(*) from matches where team1_match_type not in ('final','semifinals', 'eliminator','3rd place') group by season, batting_team1;    
    
