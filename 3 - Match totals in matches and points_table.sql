-- updating match totals (requires cleaning and EDA of deliveries)

update matches as m join (select match_id, sum(total_runs) as total1 from deliveries where inning = 1 group by match_id) as d on m.match_id = d.match_id set team1_runs = total1 where m.season <= 2017;
update matches as m join (select match_id, sum(total_runs) as total2 from deliveries where inning = 2 group by match_id) as d on m.match_id = d.match_id set team2_runs = total2 where m.season <= 2017;
select match_id, season, result_type, batting_team1, batting_team2, team1_runs, team2_runs, if (team2_runs>=team1_runs,'win by wickets', team1_runs- team2_runs) as win_margin,win_by_runs, case when (if(team2_runs>=team1_runs,'win by wickets', team1_runs- team2_runs)) = win_by_runs then 0 else 1 end as test from matches order by test desc,date;
-- match_id, season, batting_team1, batting_team2, team1_runs, team1_wickets, team1_overs, team2_runs, team2_wickets, team2_overs  

CREATE TABLE if not exists `point_table` (
  `season` int NOT NULL,
  `team` varchar(45) NOT NULL,
  `matches_played` smallint DEFAULT NULL,
  `home_wins` smallint DEFAULT NULL,
  `home_losses` smallint DEFAULT NULL,
  `home_no_result` smallint DEFAULT NULL,
  `away_wins` smallint DEFAULT NULL,
  `away_losses` smallint DEFAULT NULL,
  `away_no_result` smallint DEFAULT NULL,
  `points` smallint DEFAULT NULL,
  `group` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- NOTE: Dont compare match totals in case of DL matches