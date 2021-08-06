#################### MANAGING DUPLICATE AND EXTRA BALLS ####################
-- duplicate balls or 10th ball error
select match_id, inning, `over`, ball,max(ball_id), count(ball) from deliveries group by match_id, inning, `over`, ball having count(ball) > 1; 
-- Out of these, for balls in seasons < 2018 or season = 2020, they are the 10th balls of the over but have been labelled as 1
UPDATE deliveries SET ball = 10 WHERE ball_id in (3716,19503,23669,49605,52179,79215,86626,110667,126783,186488); 
-- The rest are just duplicate balls (and are balls in seasons 2018 and 2019, so can be deleted using season-filter query) so deleting them
delete from deliveries where ball_id in (162806,162807,162871,162965,166611,167991,168081,169405,170111,170112,170118,170120,170121,171643,171686,172217,173345,174899,175559,175690,176029,177873,178862 );

-- Overs without 6 legal deliveries - extras balls considered normal balls(>6) or some balls are missing(<6)
select t1.match_id, t1.inning, t1.max_over, t2.`over`,minBall, maxBall, t2.left_over_balls, t1.max_over =  t2.`over` as test from
(select match_id, inning, max(`over`) as max_over from deliveries group by match_id, inning) as t1 join 
(select match_id, inning,`over`, min(ball_id) as minBall, max(ball_id) as maxBall, count(ball)-6 as left_over_balls from deliveries where noball_runs = 0 and (extras_type != 'wides' or extras_type is null) group by match_id, inning, `over` having count(ball) != 6) as t2 
on t1.match_id = t2.match_id and t1.inning = t2.inning where (t1.max_over =  t2.`over`) = 0;

-- updating some balls which were extras but were recorded as normal balls
update deliveries set extras_type = 'wides (p)' where ball_id =112094; -- 414
update deliveries set noball_runs = 1 where ball_id =180418; -- 870
update deliveries set noball_runs = 1 where ball_id =181123; -- 851
update deliveries set noball_runs = 1 where ball_id =181223; -- 851
update deliveries set noball_runs = 1 where ball_id =183500; -- 834
update deliveries set noball_runs = 1 where ball_id =183787; -- 848
UPDATE deliveries SET noball_runs = 1 WHERE ball_id = 187558; -- 837

-- inserting balls where over has 5 legal deliveries AFTER verifying with match commentaries and players' stats 
insert into deliveries (match_id, inning, `over`, ball, batsman, non_striker, bowler, noball_runs, batsman_runs, extra_runs, total_runs, player_dismissed, dismissal_kind, fielder) values 
(6,1,8,8,'JR Hopes','Yuvraj Singh','D Salunkhe',0,0,0,0,NULL,NULL,NULL),
(34,2,15,8,'AD Mascarenhas','SR Watson','A Mishra',0,0,0,0,NULL,NULL,NULL),
(180,1,6,4,'AM Nayar','Sunny Singh','M Kartik',0,0,0,0,NULL,NULL,NULL);
-- Deleting bizarre 7th ball in the source website that have been duplicated/ are dot balls
delete from deliveries where ball_id in (16897,30944,52947,151390,159867,166713); -- 72,133, 224, 7897,7933,11145

-- Updating cases where wickets have fallen and/or extras_ball and havent been registered into the file, leading to 7 legal deliveries balls 
update deliveries set player_dismissed = 'JJ Roy', dismissal_kind = 'stumped', fielder = 'KD Karthik', extra_runs = 1, extras_type = 'wides' where ball_id = 153404; -- 721
update deliveries set player_dismissed = 'Mandeep Singh', dismissal_kind = 'stumped', fielder = 'Ishan Kishan', extra_runs = 1, extras_type = 'wides' where ball_id = 153676; -- 722
update deliveries set player_dismissed = 'SR Watson', dismissal_kind = 'stumped', fielder = 'RR Pant',extra_runs = 1, extras_type = 'wides', batsman_runs = 0, total_runs = 1 where ball_id = 165872; -- 773, -- (does not include extra runs duplicated in batsman_runs and total_runs)
update deliveries set player_dismissed = 'C de Grandhomme', dismissal_kind = 'run out', fielder = 'B Kumar',batsman_runs = 1,total_runs = 2, extra_runs = 1, noball_runs = 1 where ball_id = 167430; -- 779, (includes extra runs duplicated in batsman_runs and total_runs)
update deliveries set batsman_runs = 0, extras_type = 'byes', extra_runs = 4, noball_runs = 1 where ball_id = 172382; -- 800, (does not include extra runs duplicated in batsman_runs and total_runs)
update deliveries set player_dismissed = 'S Dhawan', dismissal_kind = 'stumped', fielder = 'W Saha',extra_runs = 1, extras_type = 'wides', batsman_runs = 0, total_runs = 1 where ball_id = 178514; -- 826 (does not include extra runs duplicated in batsman_runs and total_runs) NOTE: not included in counting legal ball deliveries as it occurs in the max/last over
update deliveries set player_dismissed = 'DJ Hooda', dismissal_kind = 'run out', fielder = 'RR Pant',total_runs = 2, extra_runs = 1, extras_type = 'wides' where ball_id = 178465; -- 826, (includes extra runs duplicated in batsman_runs and total_runs)

-- for 2020 > seasons > 2017, extra_runs wrongly added to batsman runs as well .. hence, batsman_runs = batsman_runs - extra_runs
update deliveries set batsman_runs = batsman_runs - extra_runs where (match_id between 709 and 828) and ball_id not in (165872,172382,178514);
update deliveries set total_runs = batsman_runs + extra_runs where (match_id between 709 and 828) and ball_id not in (165872,172382,178514);

-- balls with caught out wickets but fielder column is null
update deliveries set fielder = 'JP Duminy (sub)' where ball_id = 153677; -- 7907
-- 27 rows without fielder name but run out or catch out, will complete them in a future update

-- Cases of retired hurts not mentioned in the DB that would wreak havoc in the updated deliveries.csv created using python
update deliveries set player_dismissed = 'KC Sangakkara',dismissal_kind = 'retired hurt' where ball_id = 18894;
update deliveries set player_dismissed = 'SR Tendulkar',dismissal_kind = 'retired hurt' where ball_id = 49901;
update deliveries set player_dismissed = 'AC Gilchrist',dismissal_kind = 'retired hurt' where ball_id = 77689;
update deliveries set player_dismissed = 'SS Tiwary',dismissal_kind = 'retired hurt' where ball_id = 88924;
update deliveries set player_dismissed = 'S Dhawan', dismissal_kind = 'retired hurt' where ball_id = 98044;
update deliveries set player_dismissed = 'KM Jadhav', dismissal_kind = 'retired hurt' where ball_id = 150661;
update deliveries set player_dismissed = 'CH Gayle', dismissal_kind = 'retired hurt' where ball_id = 159861;
update deliveries set player_dismissed = 'R Salam', dismissal_kind = 'retired hurt' where ball_id = 165453;
update deliveries set player_dismissed = 'CA Lynn', dismissal_kind = 'retired hurt' where ball_id = 171642;

#################### UPDATING MATCHES TABLE WITH INNINGS' SCORES ####################
update matches as m join (select match_id, sum(total_runs) as total1 from deliveries where inning = 1 group by match_id) as d on m.match_id = d.match_id set team1_runs = total1;
update matches as m join (select match_id, sum(total_runs) as total2 from deliveries where inning = 2 group by match_id) as d on m.match_id = d.match_id set team2_runs = total2;

-- can be combined by joining with 2 subqueries
update matches as m join (select match_id, floor(count(ball)/6) + round((count(ball)%6)/10,1) as overs from deliveries where noball_runs = 0 and (extras_type != 'wides' or extras_type is null) and inning=2 group by match_id) as d on m.match_id = d.match_id set team2_overs = overs;
update matches as m join (select match_id, floor(count(ball)/6) + round((count(ball)%6)/10,1) as overs from deliveries where noball_runs = 0 and (extras_type != 'wides' or extras_type is null) and inning=1 group by match_id) as d on m.match_id = d.match_id set team1_overs = overs;

update matches as m join (select match_id, count(ball) as wickets from deliveries where player_dismissed is not null and inning =1 and dismissal_kind != 'retired hurt' group by match_id) as d on m.match_id = d.match_id set team1_wickets = wickets;
update matches as m join (select match_id, count(ball) as wickets from deliveries where player_dismissed is not null and inning =2 and dismissal_kind != 'retired hurt' group by match_id) as d on m.match_id = d.match_id set team2_wickets = wickets;

#################### POINTS TABLE####################
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

-- FOR NET RUN RATE CALCULATION (NOT CONSIDERING DL-APPLIED/ NO-RESULT MATCHES)
-- If a teams gets all out within X (<20) overs, irrespective of the innings, then it will be counted as 20 overs 
-- Howeverm if a team successfully chases a target, then the overs added in their For (and opponent's away) tally will be the overs required by them to chase the total 

drop table if exists team_stats;
create temporary table team_stats
select batting_team1, match_id, year(date) season, `date`,`time`, team1_match_type,toss_winner, result_type, (case when winner = team then 2 when winner ='NR' then 1 else 0 end) points, team1_runs, team1_wickets, if(team1_wickets != 10, team1_overs, 20.0) as team1_overs, team2_runs, team2_wickets, if(team2_wickets != 10, team2_overs, 20.0) as team2_overs from matches WHERE batting_team1 = team and team1_match_type not in ('final','3rd place','semifinals','eliminator') union 
select batting_team2, match_id, year(date) season, `date`,`time`, team2_match_type,toss_winner, result_type, (case when winner = team then 2 when winner ='NR' then 1 else 0 end) points, team2_runs, team2_wickets, if(team2_wickets != 10, team2_overs, 20.0) as team2_overs, team1_runs, team1_wickets, if(team1_wickets != 10, team1_overs, 20.0) as team1_overs from matches WHERE batting_team2 = team and team2_match_type not in ('final','3rd place','semifinals','eliminator');

insert into team_season_matches (`team`,`match_id`,`season`,`match_date`,`match_time`,`match_type`,toss_winner,`result`,`winner`,`runs_scored`,`wickets_fallen`,`overs_played`,`opp_runs`,`opp_wickets`,`opp_overs`)
select * from team_stats;

insert into points_table (`season`,`team`,`matches_played`,`points` ,`wins`,`losses`,`no_results`,`for_runs`,`for_wickets`,`for_overs`,`away_runs`,`away_wickets`,`away_overs`,`tosses_won`)
select season, batting_team1, count(match_id) played, sum(points) total_points, 
	count(case when points = 2 then 1 else null end) wins,
	count(case when points = 0 then 1 else null end) losses,
	count(case when points = 1 then 1 else null end) no_results,
    sum(team1_runs) runs_for, sum(team1_wickets) wickets_for, round(floor(sum(floor(team1_overs)*6 + (team1_overs*10)%10)/6) + (sum(floor(team1_overs)*6 + (team1_overs*10)%10)%6)/10,1) as overs_for,
    sum(team2_runs) runs_against, sum(team2_wickets) wickets_against, round(floor(sum(floor(team2_overs)*6 + (team2_overs*10)%10)/6) + (sum(floor(team2_overs)*6 + (team2_overs*10)%10)%6)/10,1) overs_against,count(case when toss_winner = team then 1 else null end) tosses_won from team_stats group by season;

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