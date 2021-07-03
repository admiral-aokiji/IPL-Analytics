-- updating match totals (requires cleaning and EDA of deliveries)

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
