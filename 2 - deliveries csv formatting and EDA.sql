drop table if exists deliveries;

-- jugaad for automatic PK generation
CREATE TABLE if not exists `deliveries` (
  `ball_id` int unsigned NOT NULL AUTO_INCREMENT,
  `match_id` int unsigned NOT NULL,
  `inning` int DEFAULT NULL,
  `batting_team` varchar(30) NOT NULL,
  `bowling_team` varchar(30) NOT NULL,
  `over` smallint NOT NULL,
  `ball` smallint NOT NULL,
  `batsman` varchar(30) NOT NULL,
  `non_striker` varchar(30) NOT NULL,
  `bowler` varchar(30) NOT NULL,
  `is_super_over` smallint DEFAULT 0,
  `wide_runs` int DEFAULT NULL,
  `bye_runs` int DEFAULT NULL,
  `legbye_runs` int DEFAULT 0,
  `noball_runs` int DEFAULT 0,
  `penalty_runs` int DEFAULT 0,
  `batsman_runs` int DEFAULT 0,
  `extra_runs` int DEFAULT 0,
  `total_runs` int DEFAULT 0,
  `player_dismissed` varchar(30) DEFAULT NULL,
  `dismissal_kind` varchar(30) DEFAULT NULL,
  `fielder` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`ball_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

load data local infile 'D:/work/pythonPractice/big projects/IPL Analytics/work/deliveries.csv'  -- add your own path here
into table deliveries
fields terminated by ','
enclosed by '"' lines
terminated by '\n'
ignore 1 lines;

update deliveries set batting_team = 'Rising Pune Supergiants' where batting_team = 'Rising Pune Supergiant';
update deliveries set bowling_team = 'Rising Pune Supergiants' where bowling_team = 'Rising Pune Supergiant';
update deliveries set batting_team = (select team_short_name from teams where deliveries.batting_team = teams.team_name);
update deliveries set bowling_team = (select team_short_name from teams where deliveries.bowling_team = teams.team_name);

-- inserting missing crucial super over balls, solving imcorrect data entry in case of super overs and removing the is_super_over column itself to trim the table size
update deliveries set is_super_over = 1 where inning > 2 and is_super_over = 0;
update deliveries set inning = 4 where inning = 5;
insert into deliveries (match_id, inning, batting_team, bowling_team, `over`, ball, batsman, non_striker, bowler, is_super_over, wide_runs, bye_runs, legbye_runs, noball_runs, penalty_runs, batsman_runs, extra_runs, total_runs, player_dismissed, dismissal_kind, fielder) values 
		(11146,3,'DC','KKR',1,3,'SS Iyer','RR Pant','P Krishna'         ,1,0,0,0,0,0,0,0,0,'SS Iyer','caught','PP Chawla'),
		(11146,4,'KKR','DC',1,3,'AD Russell','KD Karthik','K Rabada'    ,1,0,0,0,0,0,0,0,0,'AD Russell', 'bowled',''),
		(11342,3,'SRH','MI',1,1,'MK Pandey','Mohammad Nabi','JJ Bumrah' ,1,0,0,0,0,0,1,0,1,'MK Pandey','run out','KH Pandya'),
		(11342,3,'SRH','MI',1,4,'Mohammad Nabi','MJ Guptill','JJ Bumrah',1,0,0,0,0,0,0,0,0,'Mohammad Nabi','bowled','');        
create table if not exists super_over_balls as select * from deliveries where is_super_over = 1; 
delete from deliveries where is_super_over = 1;
alter table deliveries drop column is_super_over;

-- for easier querying of dismissals
update deliveries set player_dismissed = null where player_dismissed = '';
update deliveries set dismissal_kind= null where dismissal_kind = '';
update deliveries set fielder = null where fielder = '\r';


-- duplicate balls or 10th ball error
select match_id, inning, `over`, ball, count(ball) from deliveries group by match_id, inning, `over`, ball having count(ball) > 1; 
-- Overs with >6 legal deliveries - extras balls considered normal balls
select match_id, inning,`over`, count(ball)-6, max(ball_id) from deliveries where wide_runs = 0 and noball_runs = 0 group by match_id, inning, `over` having count(ball) >6;
 
delete from deliveries where ball_id in (16897,162806,162807,162871,162965,166611,167991,168081,169405,170111,170112,170118,170120,170121,171643,171686,172217,173345,174899,175559,175690,176029,177873,178862 ); -- duplicate balls
UPDATE deliveries SET ball = 10 WHERE ball_id in (3716,19503,23669,49605,52179,79215,86626,110667,126783); -- 16,83,102, 210,221,336,367,467,534 - 10th ball error
delete from deliveries where ball_id in (16897,30943,52947,151390,153679,159867,165874,166713); -- bizarre 7th ball in the source website
update deliveries set player_dismissed = 'JJ Roy', dismissal_kind = 'stumped', fielder = 'DK Karthik', extra_runs = 1, wide_runs = 1 where ball_id = 153404;
update deliveries set fielder = '(sub) JP Duminy' where ball_id = 153677;
update deliveries set player_dismissed = 'Mandeep Singh', dismissal_kind = 'stumped', fielder = 'IS Kishan', extra_runs = 1, wide_runs = 1 where ball_id = 153676;

-- 11413, 11323 - wickets have fallen but not registered in dataset+ extras balls considered normal balls
update deliveries set player_dismissed = 'C de Grandhomme', dismissal_kind = 'run out', fielder = 'B Kumar',batsman_runs = 2,total_runs = 3, extra_runs = 1, noball_runs = 1 where ball_id = 167430; -- (includes extra runs duplicated in batsman_runs and total_runs)
update deliveries set player_dismissed = 'DJ Hooda', dismissal_kind = 'run out', fielder = 'RR Pant',total_runs = 2, extra_runs = 1, wide_runs = 1 where ball_id = 178465; -- (includes extra runs duplicated in batsman_runs and total_runs)
update deliveries set batsman_runs = 0, bye_runs = 3, extra_runs = 1, noball_runs = 1 where ball_id = 172382; -- (does not include extra runs duplicated in batsman_runs and total_runs)

-- wide runs added to batsman runs as well hence batsman runs = 0 for seasons > 2016 --> saare extras batsman runs mei add ho rahe h, to baaki cases mei batsman_runs = batsman_runs - extra_runs
-- update deliveries set batsman_runs = 0, total_runs = extra_runs where wide_runs > 0 and match_id > 7890;