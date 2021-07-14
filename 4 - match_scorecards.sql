drop table if exists match_batsman_scorecards;
drop table if exists match_over_scorecards;

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
  runs_on_board SMALLINT UNSIGNED default 0,
  overs_on_arrival DECIMAL(3,1) default 0,
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
DROP PROCEDURE getOverStats;

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
select match_id, inning, bowler, count(overs), sum(runs), sum(wickets), sum(dot_balls),sum(fours) + sum(sixes) as boundaries from match_over_scorecards group by match_id, inning, bowler having sum(runs) >= 50; 