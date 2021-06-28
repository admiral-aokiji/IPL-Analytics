drop table if exists matches;

CREATE TABLE if not exists `matches` (
  `match_id` int unsigned NOT NULL ,
  `season` MEDIUMINT NOT NULL,
  `city` varchar(30) DEFAULT NULL,
  `date` text NOT NULL,
  `team1` varchar(30) NOT NULL,
  `team2` varchar(30) NOT NULL,
  `toss_winner` varchar(30) DEFAULT 'NR',
  `toss_decision` varchar(30) DEFAULT 'NR',
  `result` varchar(10) DEFAULT 'no result',
  `dl_applied` SMALLINT DEFAULT 0,
  `winner` varchar(30) DEFAULT 'NR',
  `win_by_runs` SMALLINT DEFAULT 0,
  `win_by_wickets` SMALLINT DEFAULT 0,
  `player_of_match` varchar(30) DEFAULT 'NR',
  `venue` varchar(60) NOT NULL,
  PRIMARY KEY (`match_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

load data local infile 'D:/work/pythonPractice/ML/cricket data/Indian Premier League/work/matches.csv' 
into table matches
fields terminated by ','
enclosed by '"' lines
terminated by '\n'
ignore 1 lines;

insert into matches (match_id, season, city, date, team1, team2, venue) 
VALUES (701, 2008, 'Delhi', '2008-05-22', 'Delhi Daredevils', 'Kolkata Knight Riders', 'Feroz Shah Kotla Ground'),
		(702, 2009, 'Durban', '2009-04-21', 'Mumbai Indians', 'Rajasthan Royals', 'Kingsmead'),
        (703, 2009, 'Cape Town', '2009-04-25', 'Chennai Super Kings', 'Kolkata Knight Riders', 'Newlands');
        
update matches set city = 'Dubai' where city = '';
update matches set city = 'Bengaluru' where city = 'Bangalore';
update matches set city = 'Chandigarh' where city = 'Mohali';
update matches set venue = 'M Chinnaswamy Stadium' where venue = 'M. Chinnaswamy Stadium';
update matches set venue = 'MA Chidambaram Stadium, Chepauk' where venue = 'M. A. Chidambaram Stadium';
update matches set venue = 'Punjab Cricket Association Stadium, Mohali' where venue = 'Punjab Cricket Association IS Bindra Stadium, Mohali';
update matches set venue = 'Punjab Cricket Association Stadium, Mohali' where venue = 'IS Bindra Stadium';
update matches set venue = 'Feroz Shah Kotla Ground' where venue = 'Feroz Shah Kotla';
update matches set venue = 'Rajiv Gandhi Intl. Cricket Stadium' where venue = 'Rajiv Gandhi International Stadium, Uppal';
update matches set venue = 'ACA-VDCA Stadium' where venue = 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium';
update matches set team1 = 'Rising Pune Supergiants' where team1 = 'Rising Pune Supergiant';
update matches set team2 = 'Rising Pune Supergiants' where team2 = 'Rising Pune Supergiant';
update matches set winner = 'Rising Pune Supergiants' where winner = 'Rising Pune Supergiant';
update matches set toss_winner = 'Rising Pune Supergiants' where toss_winner = 'Rising Pune Supergiant';

-- CREATE TABLE if not exists `venues` (
--   `venue_id` int unsigned NOT NULL AUTO_INCREMENT,
--   `venue_name` varchar(100) DEFAULT NULL,
--   `city` varchar(45) DEFAULT NULL,
--   `nation` varchar(45) DEFAULT 'India',
--   PRIMARY KEY (`venue_id`)
-- ) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- insert into venues (city, venue_name)
-- select distinct city, venue from matches;
-- nation column changed manually
-- get stadium stats from sportsf1.com

-- CREATE TABLE IF NOT EXISTS `teams` (
--   `team_id` int unsigned NOT NULL AUTO_INCREMENT,
--   `team_name` varchar(45) DEFAULT NULL,
--   `status` tinyint DEFAULT '1',
--   `parent_team_id` int DEFAULT NULL,
--   `team_short_name` varchar(5) DEFAULT NULL,
--   PRIMARY KEY (`team_id`)
-- ) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- insert into teams (team_name)
-- select distinct team1 from matches;
-- parent_team_id and team_short_name changed manually

update matches set team2 = (select team_short_name from teams where matches.team2 = teams.team_name);
update matches set team1 = (select team_short_name from teams where matches.team1 = teams.team_name);
update matches set toss_winner = (select team_short_name from teams where matches.toss_winner = teams.team_name);
update matches set winner = (select team_short_name from teams where matches.winner = teams.team_name);
update matches set result = 'DL applied' where  dl_applied = 1;
alter table matches add column venue_id smallint default null after city;
update matches as m, venues as v set m.venue_id= v.venue_id where m.city = v.city and m.venue= v.venue_name;
alter table matches drop column dl_applied, drop column city, drop COLUMN venue;
update matches set winner = 'NR' where winner is null;
update matches set player_of_match = 'NR' where player_of_match = '';
update matches set date = str_to_date(date, '%d/%m/%Y') where season in (2018,2019);
alter table matches modify column date DATE;
update matches set toss_winner = 'NR' where toss_winner is null;

-- if chasing team won, then how many balls left
-- if target setting team won, then were any wickets left


-- Create playoffs and group stage views


-- CREATE TABLE if not exists `point_table` (
--   `season` int NOT NULL,
--   `team` varchar(45) NOT NULL,
--   `matches_played` smallint DEFAULT NULL,
--   `home_wins` smallint DEFAULT NULL,
--   `home_losses` smallint DEFAULT NULL,
--   `home_no_result` smallint DEFAULT NULL,
--   `away_wins` smallint DEFAULT NULL,
--   `away_losses` smallint DEFAULT NULL,
--   `away_no_result` smallint DEFAULT NULL,
--   `points` smallint DEFAULT NULL,
--   `group` varchar(2) DEFAULT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
