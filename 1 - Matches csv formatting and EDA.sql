use ipl_matches;
drop table if exists matches;
drop table if exists teams;
drop table if exists venues;

CREATE TABLE if not exists `matches` (
  `match_id` int unsigned NOT NULL ,
  `season` MEDIUMINT NOT NULL,
  `city` varchar(30) DEFAULT NULL,
  `date` text NOT NULL,
  `batting_team1` varchar(30) NOT NULL,
  `batting_team2` varchar(30) NOT NULL,
  `toss_winner` varchar(30) DEFAULT 'NR',
  `toss_decision` varchar(30) DEFAULT 'NR',
  `result_type` varchar(10) DEFAULT 'no result',
  `dl_applied` SMALLINT DEFAULT 0,
  `winner` varchar(30) DEFAULT 'NR',
  `win_by_runs` SMALLINT DEFAULT 0,
  `win_by_wickets` SMALLINT DEFAULT 0,
  `player_of_match` varchar(30) DEFAULT 'NR',
  `venue` varchar(60) NOT NULL,
  PRIMARY KEY (`match_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

load data local infile 'D:/work/pythonPractice/big projects/IPL Analytics/work/matches.csv' -- add your own path here
into table matches
fields terminated by ','
enclosed by '"' lines
terminated by '\n'
ignore 1 lines;

insert into matches (match_id, season, city, date, batting_team1, batting_team2, venue) 
VALUES (701, 2008, 'Delhi', '2008-05-22', 'Delhi Daredevils', 'Kolkata Knight Riders', 'Feroz Shah Kotla Ground'),
		(702, 2009, 'Durban', '2009-04-21', 'Mumbai Indians', 'Rajasthan Royals', 'Kingsmead'),
        (703, 2009, 'Cape Town', '2009-04-25', 'Chennai Super Kings', 'Kolkata Knight Riders', 'Newlands'),
        (704, 2011, 'Bengaluru', '2011-04-19', 'Royal Challengers Bangalore', 'Rajasthan Royals', 'M Chinnaswamy Stadium'),
        (705, 2012, 'Kolkata', '2012-04-24', 'Deccan Chargers', 'Kolkata Knight Riders', 'Eden Gardens'),
        (706, 2012, 'Bengaluru', '2012-04-25', 'Chennai Super Kings', 'Royal Challengers Bangalore', 'M Chinnaswamy Stadium'),
        (707, 2015, 'Kolkata', '2015-04-26', 'Rajasthan Royals', 'Kolkata Knight Riders', 'Eden Gardens'),
        (708, 2017, 'Bengaluru', '2017-04-25', 'Royal Challengers Bangalore', 'Sunrisers Hyderabad', 'M Chinnaswamy Stadium');

update matches set date = '2014-05-28' where match_id = 514;        
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
update matches set batting_team1 = 'Rising Pune Supergiants' where batting_team1 = 'Rising Pune Supergiant';
update matches set batting_team2 = 'Rising Pune Supergiants' where batting_team2 = 'Rising Pune Supergiant';
update matches set winner = 'Rising Pune Supergiants' where winner = 'Rising Pune Supergiant';
update matches set toss_winner = 'Rising Pune Supergiants' where toss_winner = 'Rising Pune Supergiant';
update matches set date = str_to_date(date, '%d/%m/%Y') where season in (2018,2019);
alter table matches modify column date DATE;

CREATE TABLE if not exists `venues` (
  `venue_id` int unsigned NOT NULL AUTO_INCREMENT,
  `stadium` varchar(100) DEFAULT NULL,
  `city` varchar(45) DEFAULT NULL,
  `nation` varchar(45) DEFAULT 'India',
  PRIMARY KEY (`venue_id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into venues (city, stadium)
select distinct city, venue from matches;
update venues set nation = 'UAE' WHERE city in ('Sharjah', 'Abu Dhabi', 'Dubai');
update venues set nation = 'South Africa' WHERE city in (select DISTINCT city from matches where season = 2009);
-- get stadium stats from sportsf1.com

-- team1 = batting first team always. Thus, team1 column from matches.csv renamed to batting_team1. Also, if toss_winner = team1, then toss_decision = bat. However, if toss_winner = team2, then toss_decision = field.
alter table matches add column venue_id smallint default null after city;
update matches as m, venues as v set m.venue_id= v.venue_id where m.city = v.city and m.venue= v.stadium;
update matches set result_type = 'DL applied' where  dl_applied = 1;
alter table matches drop column dl_applied, drop column city, drop COLUMN venue, drop column toss_decision;
update matches set winner = 'NR' where winner = '';
update matches set player_of_match = 'NR' where player_of_match = '';

CREATE TABLE IF NOT EXISTS `teams` (
  team_id SMALLINT unsigned NOT NULL AUTO_INCREMENT,
  `team_name` varchar(45) DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  parent_team_id int DEFAULT NULL,
  team_short_name varchar(5) DEFAULT NULL,
  home_stadium1 smallint DEFAULT NULL,
  home_stadium2 smallint DEFAULT NULL,
  PRIMARY KEY (team_id)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into teams (team_name)
select distinct batting_team1 from matches;

UPDATE teams SET parent_team_id = '31', team_short_name = 'SRH', home_stadium1 = 64, home_stadium2 = 91 WHERE (team_id = '31');
UPDATE teams SET parent_team_id = '32', team_short_name = 'MI', home_stadium1 = 69, home_stadium2 = 76 WHERE (team_id = '32');
UPDATE teams SET parent_team_id = '33', team_short_name = 'GL', home_stadium1 = 66, home_stadium2 = 73, status = 0 WHERE (team_id = '33');
UPDATE teams SET parent_team_id = '34', team_short_name = 'RPS', home_stadium1 = 92, home_stadium2 = 65, status = 0 WHERE (team_id = '34');
UPDATE teams SET parent_team_id = '35', team_short_name = 'RCB', home_stadium1 = 68 WHERE (team_id = '35');
UPDATE teams SET parent_team_id = '36', team_short_name = 'KKR', home_stadium1 = 70 WHERE (team_id = '36');
UPDATE teams SET parent_team_id = '38', team_short_name = 'KXIP', home_stadium1 = 72, home_stadium2 = 89 WHERE (team_id = '38');
UPDATE teams SET parent_team_id = '39', team_short_name = 'CSK', home_stadium1 = 75, home_stadium2 = 94 WHERE (team_id = '39');
UPDATE teams SET parent_team_id = '40', team_short_name = 'RR', home_stadium1 = 74, home_stadium2 = 86 WHERE (team_id = '40');
UPDATE teams SET parent_team_id = '31', team_short_name = 'SRH', home_stadium1 = 64, home_stadium2 = 91, status = 0 WHERE (team_id = '41');
UPDATE teams SET parent_team_id = '42', team_short_name = 'KTK', home_stadium1 = 90, home_stadium2 = 67, status = 0 WHERE (team_id = '42');
UPDATE teams SET parent_team_id = '34', team_short_name = 'RPS', home_stadium1 = 92, home_stadium2 = 65, status = 0 WHERE (team_id = '43');
UPDATE teams SET parent_team_id = '44', team_short_name = 'DC', home_stadium1 = 71, home_stadium2 = 93 WHERE (team_id = '44');
UPDATE teams SET parent_team_id = '44', team_short_name = 'DC', home_stadium1 = 71, home_stadium2 = 93, status = 0 WHERE (team_id = '37');

update matches set batting_team2 = (select team_short_name from teams where matches.batting_team2 = teams.team_name);
update matches set batting_team1 = (select team_short_name from teams where matches.batting_team1 = teams.team_name);
update matches set toss_winner = (select team_short_name from teams where matches.toss_winner = teams.team_name) where toss_winner != 'NR';
update matches set winner = (select team_short_name from teams where matches.winner = teams.team_name) where winner != 'NR';

alter table matches add column `time` varchar(5) default 'night' after date,
					add column team1_match_type varchar(10) default 'neutral' after toss_winner,
					add column team2_match_type varchar(10) default 'neutral' after team1_match_type,
                    add column team1_runs mediumint default 0 after winner,
                    add column team1_wickets smallint default 0 after team1_runs,
                    add column team1_overs DECIMAL(2,1) default 0.0 after team1_wickets,
                    add column team2_runs mediumint default 0 after team1_overs,
                    add column team2_wickets smallint default 0 after team2_runs,
                    add column team2_overs DECIMAL(2,1) default 0.0 after team2_wickets;

update matches as t1 join (select date, min(match_id) min_id from matches group by date having count(match_id) > 1) as t2 on t1.match_id = t2.min_id set time = 'day'; 

create temporary table matches2 (final_date date not null);
insert into matches2
select max(date) from matches group by season order by date;
update matches as t1 set team1_match_type = 'final', team2_match_type = 'final' where date in (select * from matches2); 

update matches set team1_match_type = '3rd place', team2_match_type = '3rd place' where match_id = 233;
update matches set team1_match_type = 'semifinals', team2_match_type = 'semifinals' where team1_match_type != 'final' and ((date> '2008-05-28' and season = 2008) or (date> '2009-05-21' and season = 2009) or (date> '2010-04-19' and season = 2010));
update matches set team1_match_type = 'eliminator', team2_match_type = 'eliminator' where team1_match_type != 'final' and ((date> '2011-05-23' and season = 2011) or (date> '2012-05-21' and season = 2012) or (date> '2013-05-20' and season = 2013) or (date> '2014-05-27' and season = 2014) or (date> '2015-05-18' and season = 2015) or (date> '2016-05-23' and season = 2016) or (date> '2017-05-15' and season = 2017) or (date> '2018-05-21' and season = 2018) or (date> '2019-05-06' and season = 2019));

-- updating home and away values based on instances where home_stadium1 values match
update matches join venues as v using (venue_id) left join teams as t on t.home_stadium1 = v.venue_id and t.team_id = t.parent_team_id set team1_match_type = 
	case when batting_team1 = team_short_name then 'home'
		 when batting_team2 = team_short_name then 'away'
         else team1_match_type
         end where team1_match_type not in ('final', 'semifinals', '3rd place', 'eliminator');

-- Reusable query         
update matches set team2_match_type = case 
		when team1_match_type='home' then 'away' 
        when team1_match_type = 'away' then 'home' 
        else team2_match_type end;
        
-- updating home and away values based on instances where home_stadium1 values match        
update matches join venues as v using (venue_id) left join teams as t on t.home_stadium2 = v.venue_id and t.team_id = t.parent_team_id 
	set team1_match_type = case 
		when batting_team2 = team_short_name then 'away' 
        when batting_team1 = team_short_name then 'home' 
        else 'neutral'
    end where team1_match_type = 'neutral' and nation ='India' and (season = 2008 or venue_id in (73,86, 89, 93));
    
-- 3rd+ home stadium cases
-- CSK 65 in 2018, 94 in 2014
-- RR 85 in 2015
-- KXIP 67 in 2017,2018, 65 in 2015
-- MI 85 in 2010, 91 in 2016
-- SRH 76,88 in 2010 (manually update some cases), 87 in 2010,12, 91 in 2012,15,16,19
-- KTK 67 in 2011  
-- RPS 76 in 2011, 91 in 2016, 92 (2012-13) main then 65 (RPS times)
-- KKR 94 in 2013
update matches set team1_match_type = case 
		when season =2010 and venue_id in (76,87,88) then if (batting_team1 = 'SRH', 'home', 'away') 
		when season =2010 and venue_id = 85 then if (batting_team1 = 'MI', 'home', 'away') 
		when season =2011 and venue_id = 67 then if (batting_team1 = 'KTK', 'home', 'away') 
		when season =2011 and venue_id = 76 then if (batting_team1 = 'RPS', 'home', 'away') 
		when season =2012 and venue_id in (87,91) then if (batting_team1 = 'SRH', 'home', 'away') 
		when season =2013 and venue_id = 94 then if (batting_team1 = 'KKR', 'home', 'away') 
		when season =2014 and venue_id = 94 then if (batting_team1 = 'CSK', 'home', 'away') 
		when season =2015 and venue_id = 91 then if (batting_team1 = 'SRH', 'home', 'away') 
		when season =2015 and venue_id = 85 then if (batting_team1 = 'RR', 'home', 'away') 
		when season =2015 and venue_id = 65 then if (batting_team1 = 'KXIP', 'home', 'away')
        when season = 2016 and venue_id = 91 then if (batting_team1 = 'MI', 'home', 'away')
        when season = 2016 and venue_id = 91 then if (batting_team2 = 'MI', 'away', 'home')
        when season = 2016 and venue_id = 91 then if (batting_team1 = 'RPS', 'home', 'away')
        when season = 2016 and venue_id = 91 then if (batting_team2 = 'RPS', 'away', 'home')
		when season in (2016,2017) and venue_id = 65 then if (batting_team1 = 'RPS', 'home', 'away') 
 		when season in (2017,2018) and venue_id = 67 then if (batting_team1 = 'KXIP', 'home', 'away') 
 		when season =2018 and venue_id = 65 then if (batting_team1 = 'CSK', 'home', 'away') 
        else 'neutral'
    end where team1_match_type = 'neutral' and season!= 2009;

