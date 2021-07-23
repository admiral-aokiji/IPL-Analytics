drop table if exists points_table;
drop table if exists team_season_matches;

CREATE TABLE IF NOT EXISTS points_table (
  entry_id int unsigned NOT NULL AUTO_INCREMENT,
  season mediumint NOT NULL,
  team varchar(45) NOT NULL,
  matches_played smallint DEFAULT 0,
  points smallint DEFAULT 0,
  wins smallint DEFAULT 0,
  losses smallint DEFAULT 0,
  no_results smallint DEFAULT 0,
  for_runs mediumint DEFAULT 0,
  for_wickets mediumint DEFAULT 0,
  for_overs decimal(5,1) DEFAULT 0.0,
  away_runs mediumint DEFAULT 0,
  away_wickets mediumint DEFAULT 0,
  away_overs decimal(5,1) DEFAULT 0.0,
  net_run_rate decimal(5,4) as (for_runs/for_overs - away_runs/away_overs),
  tosses_won smallint DEFAULT 0,
  longest_win_streak smallint DEFAULT 0,
  longest_loss_streak smallint DEFAULT 0,
  potm_awards smallint DEFAULT 0,
  PRIMARY KEY (entry_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS team_season_matches (
  entry_id int NOT NULL AUTO_INCREMENT,
  team varchar(45) DEFAULT NULL,
  match_id mediumint DEFAULT NULL,
  season smallint DEFAULT NULL,
  match_date date DEFAULT NULL,
  match_time varchar(45) DEFAULT NULL,
  match_type varchar(45) DEFAULT NULL,
  toss_winner varchar(45) DEFAULT NULL,
  result varchar(45) DEFAULT NULL,
  winner smallint DEFAULT NULL,
  runs_scored smallint unsigned DEFAULT NULL,
  wickets_fallen smallint DEFAULT NULL,
  overs_played decimal(3,1) DEFAULT NULL,
  opp_runs smallint unsigned DEFAULT NULL,
  opp_wickets smallint DEFAULT NULL,
  opp_overs decimal(3,1) DEFAULT NULL,
  PRIMARY KEY (entry_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

###########################################################################################

DROP PROCEDURE if exists getSeasonStats;
DELIMITER $$
CREATE PROCEDURE getSeasonStats (IN  team varchar(10))
BEGIN 
drop table if exists team_stats;
create temporary table team_stats
select batting_team1, match_id, season, `date`,`time`, team1_match_type,toss_winner, result_type, (case when winner = team then 2 when winner ='NR' then 1 else 0 end) points, team1_runs, team1_wickets, team1_overs, team2_runs, team2_wickets, team2_overs from matches WHERE batting_team1 = team and team1_match_type not in ('final','3rd place','semifinals','eliminator') union 
select batting_team2, match_id, season, `date`,`time`, team2_match_type,toss_winner, result_type, (case when winner = team then 2 when winner ='NR' then 1 else 0 end) points, team2_runs, team2_wickets, team2_overs, team1_runs, team1_wickets, team1_overs from matches WHERE batting_team2 = team and team2_match_type not in ('final','3rd place','semifinals','eliminator');

insert into team_season_matches (`team`,`match_id`,`season`,`match_date`,`match_time`,`match_type`,toss_winner,`result`,`winner`,`runs_scored`,`wickets_fallen`,`overs_played`,`opp_runs`,`opp_wickets`,`opp_overs`)
select * from team_stats;

insert into points_table (`season`,`team`,`matches_played`,`points` ,`wins`,`losses`,`no_results`,`for_runs`,`for_wickets`,`for_overs`,`away_runs`,`away_wickets`,`away_overs`,`tosses_won`)
select season, batting_team1, count(match_id) played, sum(points) total_points, 
	count(case when points = 2 then 1 else null end) wins,
	count(case when points = 0 then 1 else null end) losses,
	count(case when points = 1 then 1 else null end) no_results,
    sum(team1_runs) runs_for, sum(team1_wickets) wickets_for, round(floor(sum(floor(team1_overs)*6 + (team1_overs*10)%10)/6) + (sum(floor(team1_overs)*6 + (team1_overs*10)%10)%6)/10,1) as overs_for,
    sum(team2_runs) runs_against, sum(team2_wickets) wickets_against, round(floor(sum(floor(team2_overs)*6 + (team2_overs*10)%10)/6) + (sum(floor(team2_overs)*6 + (team2_overs*10)%10)%6)/10,1) overs_against,count(case when toss_winner = 'KKR' then 1 else null end) tosses_won from team_stats group by season;

-- insert into detailed_team_stats
-- select season, team1_match_type, sum(points), sum(team1_runs), sum(team1_wickets), floor(sum(floor(team1_overs)*6 + (team1_overs*10)%10)/6) + (sum(floor(team1_overs)*6 + (team1_overs*10)%10)%6), sum(team2_runs), sum(team2_wickets), sum(floor(team1_overs)*6 + (team1_overs*10)%10) from team_stats group by season, team1_match_type;

drop table team_stats;
END $$
Delimiter ;

-- Loop team_short_name for each parent_id = team_id
call getSeasonStats('KKR');
call getSeasonStats('CSK');
call getSeasonStats('DC');
call getSeasonStats('MI');
call getSeasonStats('SRH');
call getSeasonStats('RPS');
call getSeasonStats('KTK');
call getSeasonStats('GC');
call getSeasonStats('RCB');
call getSeasonStats('KXIP');
call getSeasonStats('RR');


