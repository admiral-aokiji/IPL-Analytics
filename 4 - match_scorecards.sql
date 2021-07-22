drop table if exists match_batsman_scorecards;
drop table if exists match_bowler_scorecards;
drop table if exists match_over_scorecards;

CREATE TABLE IF NOT EXISTS match_over_scorecards (
  over_id int NOT NULL AUTO_INCREMENT,
  match_id int NOT NULL,
  inning smallint NOT NULL,
  bowler varchar(45) NOT NULL,
  overs smallint NOT NULL,
  runs smallint unsigned DEFAULT '0',
  wickets smallint unsigned DEFAULT '0',
  extras smallint unsigned DEFAULT '0',
  dot_balls smallint unsigned DEFAULT '0',
  singles smallint unsigned DEFAULT '0',
  doubles smallint unsigned DEFAULT '0',
  triples smallint unsigned DEFAULT '0',
  fours smallint unsigned DEFAULT '0',
  sixes smallint unsigned DEFAULT '0',
  wide_runs smallint unsigned DEFAULT '0',
  noball_runs smallint unsigned DEFAULT '0',
  legbye_runs smallint unsigned DEFAULT '0',
  bye_runs smallint unsigned DEFAULT '0',
  penalty_runs smallint unsigned DEFAULT '0',
  PRIMARY KEY (over_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data can be inserted using either : 1. Stored functions, 2. Cursors, loops and stored procedures. As we want to insert multiple columns at once, use of 2nd option

##########################################################################################################
DROP PROCEDURE if exists getOverStats;
DELIMITER $$
CREATE PROCEDURE getOverStats (IN  startMatchID int, IN  endMatchID int)
BEGIN 
	drop table if exists wicket;
	drop table if exists run;
	drop table if exists dot;
	
    create temporary table wicket select match_id,inning, bowler, `over` overs, count(case when player_dismissed is null then null else 1 end ) wickets FROM deliveries d WHERE d.match_id between startMatchID and endMatchID group by match_id,inning, `over`;
	
    create temporary table run select match_id,inning, bowler, `over` overs, sum(total_runs) runs, sum(extra_runs) extras, count(case when batsman_runs != 1 then null else 1 end ) singles, count(case when batsman_runs != 2 then null else 1 end) doubles, count(case when batsman_runs != 3 then null else 1 end) triples, count(case when batsman_runs != 4 then null else 1 end) fours, count(case when batsman_runs != 6 then null else 1 end ) sixes, sum(wide_runs) wides, sum(noball_runs) noballs, sum(legbye_runs) legbyes, sum(bye_runs) byes, sum(penalty_runs) penalty_runs FROM deliveries d WHERE d.match_id between startMatchID and endMatchID group by match_id,inning, `over`;
	
    create temporary table dot select match_id,inning, bowler, `over` overs, count(case when total_runs != 0 then null else 1 end) dots FROM deliveries d WHERE d.match_id between startMatchID and endMatchID group by match_id,inning, `over`;
        
	INSERT INTO match_over_scorecards (match_id,inning, bowler, overs,runs, wickets,extras, dot_balls,singles, doubles, triples, fours, sixes, wide_runs,noball_runs,legbye_runs,bye_runs,penalty_runs)
select w.match_id, w.inning, w.bowler, w.overs, r.runs, w.wickets,r.extras, d.dots, r.singles, r.doubles, r.triples, r.fours, r.sixes, wides, noballs, legbyes, byes, penalty_runs from wicket w join run r on w.match_id =r.match_id and w.inning= r.inning and w.bowler= r.bowler and w.overs = r.overs join dot d on r.match_id =d.match_id and r.inning= d.inning and r.bowler= d.bowler and r.overs = d.overs ;
    
END$$
DELIMITER ;

-- observe the execution times for each case
call getOverStats(1,100);
call getOverStats(101,250);
call getOverStats(251,500);
call getOverStats(501,12000);

##########################################################################################################

CREATE TABLE IF NOT EXISTS match_bowler_scorecards
select match_id, inning, bowler,(sum(dot_balls)+ sum(fours) + sum(sixes)+sum(singles) + sum(doubles) + sum(triples) + sum(bye_runs) + sum(legbye_runs))  as balls, sum(runs) runs_conceded, sum(wickets) wickets, sum(dot_balls) dots, sum(singles) singles, sum(fours) fours, sum(sixes) sixes, sum(extras) extras, sum(wide_runs) wide_runs, sum(noball_runs) noball_runs from match_over_scorecards group by match_id, inning, bowler; 
-- automatic column value generation for overs as concat(floor(balls/6),'.',balls%6)
-- add columns bowled, caught, lbw, stumped, maidens by creating a view of all dismissals and one for maidens
-- add super_overs with innings = 3 or 4
-- Verify whether balls < 25
-- verify whether overs bowled in each innings matches with team1_overs and team2_overs of matches

-- :) DINDA ACADEMY (take average of how many boundaries these bowlers concede in a match vs the best bowlers)
select match_id, inning, bowler, count(overs), sum(runs), sum(wickets), sum(dot_balls),sum(singles),sum(doubles),sum(triples),sum(fours) + sum(sixes) as boundaries from match_over_scorecards group by match_id, inning, bowler having sum(runs) >= 50; 

##########################################################################################################

-- Instead of manually updating each row with the new values for striker_runs, striker_balls, non_striker_runs, non_striker_balls, team_runs, team_wickets and team_overs, reformatting the deliveries table in python and then reimporting the formatted deliveries.csv was found to be much faster (from ~10 hours to ~10 seconds).

drop table if EXISTS deliveries;
CREATE TABLE if not exists deliveries (
  ball_id int unsigned NOT NULL AUTO_INCREMENT,
  match_id int unsigned NOT NULL,
  inning int DEFAULT NULL,
  `over` smallint NOT NULL,
  ball smallint NOT NULL,
  batsman varchar(30) NOT NULL,
  non_striker varchar(30) NOT NULL,
  bowler varchar(30) NOT NULL,
  wide_runs int DEFAULT NULL,
  bye_runs int DEFAULT NULL,
  legbye_runs int DEFAULT 0,
  noball_runs int DEFAULT 0,
  penalty_runs int DEFAULT 0,
  batsman_runs int DEFAULT 0,
  extra_runs int DEFAULT 0,
  total_runs int DEFAULT 0,
  player_dismissed varchar(30) DEFAULT NULL,
  dismissal_kind varchar(30) DEFAULT NULL,
  fielder varchar(30) DEFAULT NULL,
  striker_runs SMALLINT unsigned default 0,
  striker_balls SMALLINT default 0,
  non_striker_runs SMALLINT unsigned default 0,
  non_striker_balls SMALLINT unsigned default 0,
  team_runs int DEFAULT 0,
  team_wickets int DEFAULT 0,
  team_overs decimal(3, 1) default 0.0,
  PRIMARY KEY (ball_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

load data local infile 'D:/work/pythonPractice/big projects/IPL Analytics/work/formatted-deliveries.csv' -- add your own path here
into table deliveries 
fields terminated by ',' 
enclosed by '"' 
lines terminated by '\n' 
ignore 1 lines;

update deliveries set player_dismissed = null where player_dismissed = '';
update deliveries set dismissal_kind= null where dismissal_kind = '';
update deliveries set fielder = null where fielder = '';

CREATE TABLE IF NOT EXISTS match_batsman_scorecards (
  batsman_inning_id INT NOT NULL AUTO_INCREMENT,
  match_id INT NOT NULL,
  inning SMALLINT NOT NULL,
  batsman VARCHAR(45) NOT NULL,
  position SMALLINT NULL,
  runs SMALLINT UNSIGNED default 0,
  balls SMALLINT UNSIGNED default 0,
  dismissal_type VARCHAR(45) NULL,
  bowler VARCHAR(45) NULL,
  fielder VARCHAR(45) NULL,
  runs_on_arrival SMALLINT UNSIGNED default 0,
  overs_on_arrival DECIMAL(3,1) default 0,
  runs_on_dismissal SMALLINT UNSIGNED default 0,
  overs_on_dismissal DECIMAL(3,1) default 0,
  end_partner_runs SMALLINT default 0,
  end_partner_balls SMALLINT default 0,
  dot_balls SMALLINT default 0,
  singles SMALLINT default 0,
  doubles SMALLINT default 0,
  triples SMALLINT default 0,
  fours SMALLINT default 0,
  sixes SMALLINT default 0,
  PRIMARY KEY (batsman_inning_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

##########################################################################################################
DROP PROCEDURE if exists getBatsmanStats;
DELIMITER $$
CREATE PROCEDURE getBatsmanStats (IN  startMatch int, IN  endMatch int)
BEGIN 
	drop table if exists strike_min, non_strike_min, position_sort, inning_stats, dismissal_stats;
    
    create TEMPORARY table inning_stats 
	select match_id, inning, batsman, sum(batsman_runs) runs, count(case when wide_runs = 0 and noball_runs = 0 then 1 else null end) balls, count(case when total_runs = 0 then 1 else null end) dots, count(case when batsman_runs = 1 then 1 else null end) singles,count(case when batsman_runs = 2 then 1 else null end) doubles, count(case when batsman_runs = 3 then 1 else null end) triples, count(case when batsman_runs = 4 then 1 else null end) fours, count(case when batsman_runs = 6 then 1 else null end) sixes from deliveries where (match_id between startMatch and endMatch) group by match_id,inning, batsman;
    
    create TEMPORARY table non_strike_min
    select match_id, inning, non_striker, min(team_overs) as str_min, min(team_runs) as min_truns, 2 as pos from deliveries where (match_id between startMatch and endMatch) GROUP BY match_id, inning, non_striker;
    create TEMPORARY table strike_min
    select match_id, inning, batsman, min(team_overs) as str_min, min(team_runs) as min_truns, 1 as pos from deliveries where (match_id between startMatch and endMatch) GROUP BY match_id, inning, batsman; 
    create TEMPORARY table position_sort
	select match_id, inning, batsman, min(str_min) overs_on_arrival, min(min_truns) as runs_on_arrival, pos, ROW_NUMBER() OVER (PARTITION BY match_id, inning ORDER BY min(str_min),pos) as str_order from (select * from strike_min UNION select * from non_strike_min order by match_id, inning, str_min) as d GROUP BY match_id, inning, batsman;
    
    create TEMPORARY table dismissal_stats
	select match_id, inning, batsman, dismissal_kind, bowler, fielder, player_dismissed, non_striker_runs as end_partner_runs, non_striker_balls as end_partner_balls, team_runs, team_overs from deliveries where player_dismissed is not null and player_dismissed = batsman and (match_id between startMatch and endMatch) union
select match_id, inning, non_striker, dismissal_kind, bowler, fielder, player_dismissed, striker_runs as end_partner_runs, non_striker_balls as end_partner_balls, team_runs,team_overs from deliveries where player_dismissed is not null and player_dismissed != batsman and (match_id between startMatch and endMatch);
    
    insert into match_batsman_scorecards (match_id, inning, batsman, position, runs, balls, dismissal_type, bowler, fielder, runs_on_arrival, overs_on_arrival,runs_on_dismissal, overs_on_dismissal, end_partner_runs, end_partner_balls, dot_balls, singles, doubles, triples, fours, sixes)
    select i.match_id, i.inning, i.batsman,p.str_order, i.runs, i.balls, d.dismissal_kind, d.bowler, d.fielder, p.runs_on_arrival, p.overs_on_arrival, d.team_runs as runs_on_dismissal, d.team_overs as overs_on_dismissal, d.end_partner_runs, d.end_partner_balls, i.dots, i.singles, i.doubles, i.triples, i.fours, i.sixes from inning_stats i join position_sort p on i.match_id = p.match_id and i.inning = p.inning and i.batsman = p.batsman left join dismissal_stats d on d.match_id = p.match_id and d.inning = p.inning and d.batsman = p.batsman;
    
    drop table strike_min, non_strike_min, position_sort, inning_stats, dismissal_stats;
	
    update match_batsman_scorecards s join matches m using (match_id) set runs_on_dismissal = m.team1_runs where s.inning =1 and s.dismissal_type is null;
	update match_batsman_scorecards s join matches m using (match_id) set overs_on_dismissal = m.team1_overs where s.inning =1 and s.dismissal_type is null;
	update match_batsman_scorecards s join matches m using (match_id) set runs_on_dismissal = m.team2_runs where s.inning =2 and s.dismissal_type is null;
	update match_batsman_scorecards s join matches m using (match_id) set overs_on_dismissal = m.team2_overs where s.inning =2 and s.dismissal_type is null;

END$$
DELIMITER ;

call getBatsmanStats(1,50);
call getBatsmanStats(51,150);
call getBatsmanStats(151,300);
call getBatsmanStats(301,500);
call getBatsmanStats(501,12000);
##########################################################################################################