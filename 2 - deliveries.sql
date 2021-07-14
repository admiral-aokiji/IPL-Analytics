drop table if exists deliveries;

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
update deliveries,teams set batting_team = team_short_name where deliveries.batting_team = teams.team_name;
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
select match_id, inning, `over`, ball,max(ball_id), count(ball) from deliveries group by match_id, inning, `over`, ball having count(ball) > 1; 
-- Out of these, for balls in seasons < 2018, they are the 10th balls of the over but have been labelled as 1
UPDATE deliveries SET ball = 10 WHERE ball_id in (3716,19503,23669,49605,52179,79215,86626,110667,126783); 
-- The rest are just duplicate balls (and are balls in seasons 2018 and 2019, so can be deleted using season-filter query) so deleting them
delete from deliveries where ball_id in (162806,162807,162871,162965,166611,167991,168081,169405,170111,170112,170118,170120,170121,171643,171686,172217,173345,174899,175559,175690,176029,177873,178862 );

-- Overs without 6 legal deliveries - extras balls considered normal balls(>6) or some balls are missing(<6)
select t1.match_id, t1.inning, t1.max_over, t2.`over`,minBall, maxBall, t2.left_over_balls, t1.max_over =  t2.`over` as test from
(select match_id, inning, max(`over`) as max_over from deliveries group by match_id, inning) as t1 join 
(select match_id, inning,`over`,min(ball_id) as minBall, max(ball_id) as maxBall, count(ball)-6 as left_over_balls from deliveries where wide_runs = 0 and noball_runs = 0 group by match_id, inning, `over` having count(ball) != 6) as t2 
on t1.match_id = t2.match_id and t1.inning = t2.inning where (t1.max_over =  t2.`over`) = 0;

-- inserting balls where over has 5 legal deliveries AFTER verifying with match commentaries and players' stats 
insert into deliveries (match_id, inning, batting_team, bowling_team, `over`, ball, batsman, non_striker, bowler, wide_runs, bye_runs, legbye_runs, noball_runs, penalty_runs, batsman_runs, extra_runs, total_runs, player_dismissed, dismissal_kind, fielder) values 
(65,1,'KXIP','RR',8,8,'JR Hopes','Yuvraj Singh','D Salunkhe',0,0,0,0,0,0,0,0,NULL,NULL,NULL),
(93,2,'RR','DC',15,8,'AD Mascarenhas','SR Watson','A Mishra',0,0,0,0,0,0,0,0,NULL,NULL,NULL),
(239,1,'KXIP','RPS',6,4,'AM Nayar','Sunny Singh','M Kartik',0,0,0,0,0,0,0,0,NULL,NULL,NULL);
-- Deleting bizarre 7th ball in the source website that have been duplicated/ are dot balls
delete from deliveries where ball_id in (16897,30944,52947,151390,159867,166713); -- 72,133, 224, 7897,7933,11145

-- Updating cases where wickets have fallen and/or extras_ball and havent been registered into the file, leading to 7 legal deliveries balls 
update deliveries set player_dismissed = 'JJ Roy', dismissal_kind = 'stumped', fielder = 'KD Karthik', extra_runs = 1, wide_runs = 1 where ball_id = 153404; -- 7906
update deliveries set player_dismissed = 'Mandeep Singh', dismissal_kind = 'stumped', fielder = 'Ishan Kishan', extra_runs = 1, wide_runs = 1 where ball_id = 153676; -- 7907
update deliveries set player_dismissed = 'SR Watson', dismissal_kind = 'stumped', fielder = 'RR Pant',extra_runs = 1, wide_runs = 1,batsman_runs = 0, total_runs = 1 where ball_id = 165872; -- 11141, -- (does not include extra runs duplicated in batsman_runs and total_runs)
update deliveries set player_dismissed = 'C de Grandhomme', dismissal_kind = 'run out', fielder = 'B Kumar',batsman_runs = 1,total_runs = 2, extra_runs = 1, noball_runs = 1 where ball_id = 167430; -- 11147, (includes extra runs duplicated in batsman_runs and total_runs)
update deliveries set batsman_runs = 0, bye_runs = 3, extra_runs = 1, noball_runs = 1 where ball_id = 172382; -- 11323, (does not include extra runs duplicated in batsman_runs and total_runs)
update deliveries set player_dismissed = 'S Dhawan', dismissal_kind = 'stumped', fielder = 'W Saha',extra_runs = 1, wide_runs = 1,batsman_runs = 0, total_runs = 1 where ball_id = 178514; -- 11413 (does not include extra runs duplicated in batsman_runs and total_runs) NOTE: not included in counting legal ball deliveries as it occurs in the max/last over
update deliveries set player_dismissed = 'DJ Hooda', dismissal_kind = 'run out', fielder = 'RR Pant',total_runs = 2, extra_runs = 1, wide_runs = 1 where ball_id = 178465; -- 11413, (includes extra runs duplicated in batsman_runs and total_runs)

-- for seasons > 2017, extra_runs wrongly added to batsman runs as well .. hence, batsman_runs = batsman_runs - extra_runs
update deliveries set batsman_runs = batsman_runs - wide_runs - noball_runs - legbye_runs - bye_runs where match_id > 800 and ball_id not in (165872,172382,178514);
update deliveries set total_runs = batsman_runs + extra_runs where match_id > 800 and ball_id not in (165872,172382,178514);

-- balls with caught out wickets but fielder column is null
update deliveries set fielder = 'JP Duminy (sub)' where ball_id = 153677; -- 7907
-- 27 rows without fielder name but run out or catch out

alter TABLE super_over_balls drop COLUMN `over`, drop COLUMN is_super_over; 
alter TABLE deliveries drop COLUMN batting_team, drop COLUMN bowling_team; 
alter table deliveries2 add COLUMN striker_runs SMALLINT unsigned default 0, add COLUMN striker_balls SMALLINT default 0, add COLUMN non_striker_runs SMALLINT unsigned default 0, add COLUMN non_striker_balls SMALLINT unsigned default 0, add COLUMN team_runs SMALLINT unsigned default 0,add COLUMN team_overs decimal(3,1) default 0.0;

-- Instead of manually updating each row with the new values for striker_runs, striker_balls, non_striker_runs, non_striker_balls and team_overs, reformatting the deliveries table in python and then reimporting the formatted deliveries.csv was found to be much faster (from ~10 hours to ~10 seconds).

drop table if EXISTS deliveries;
CREATE TABLE if not exists `deliveries` (
  `ball_id` int unsigned NOT NULL AUTO_INCREMENT,
  `match_id` int unsigned NOT NULL,
  `inning` int DEFAULT NULL,
  `over` smallint NOT NULL,
  `ball` smallint NOT NULL,
  `batsman` varchar(30) NOT NULL,
  `non_striker` varchar(30) NOT NULL,
  `bowler` varchar(30) NOT NULL,
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
  `striker_runs` SMALLINT unsigned default 0,
  `striker_balls` SMALLINT default 0,
  `non_striker_runs` SMALLINT unsigned default 0,
  `non_striker_balls` SMALLINT unsigned default 0,
  `team_overs` decimal(3, 1) default 0.0,
  PRIMARY KEY (`ball_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
load data local infile 'D:/work/pythonPractice/big projects/IPL Analytics/work/formatted-deliveries.csv' -- add your own path here
into table deliveries fields terminated by ',' enclosed by '"' lines terminated by '\n' ignore 1 lines;