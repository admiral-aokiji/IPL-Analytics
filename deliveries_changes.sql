drop table if exists deliveries;
CREATE TABLE if not exists `deliveries` (
  `match_id` int DEFAULT NULL,
  `inning` int DEFAULT NULL,
  `batting_team` text,
  `bowling_team` text,
  `over` int DEFAULT NULL,
  `ball` int DEFAULT NULL,
  `batsman` text,
  `non_striker` text,
  `bowler` text,
  `is_super_over` int DEFAULT NULL,
  `wide_runs` int DEFAULT NULL,
  `bye_runs` int DEFAULT NULL,
  `legbye_runs` int DEFAULT NULL,
  `noball_runs` int DEFAULT NULL,
  `penalty_runs` int DEFAULT NULL,
  `batsman_runs` int DEFAULT NULL,
  `extra_runs` int DEFAULT NULL,
  `total_runs` int DEFAULT NULL,
  `player_dismissed` text,
  `dismissal_kind` text,
  `fielder` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

load data local infile 'D:/work/pythonPractice/ML/cricket data/Indian Premier League/work/deliveries.csv' 
into table deliveries
fields terminated by ','
enclosed by '"' lines
terminated by '\n'
ignore 1 lines;
