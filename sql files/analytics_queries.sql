################ SOME USEFUL QUERIES (NOT STORED AS VIEWS) ##################
select match_id, inning, max(`over`) max_over, floor(count(ball)/6) + round((count(ball)%6)/10,1) overs from deliveries where wide_runs=0 and noball_runs=0 group by match_id, inning;




################ BOWLER ANALYTICS ##################
-- bowler stats in depth. subtract extras runs if you want
select bowler,max(runs_conceded),count(*) innings,sum(fours) + sum(sixes) boundaries,sum(wickets) wickets, round(sum(runs_conceded)/sum(balls)*6,2) economy_rate,count(case when runs_conceded >= 50 then 1 else null end) as dinda_innings from match_bowler_scorecards group by bowler having innings > 16 order by economy_rate; 
-- bowler stats in depth split into seasons. A new column for performance score can be added
select season, bowler,max(runs_conceded),count(*) innings, sum(wickets) wickets, round(sum(runs_conceded)/sum(balls)*6,2) economy_rate,count(case when runs_conceded >= 50 then 1 else null end) as dinda_innings from match_bowler_scorecards as b join matches as m using (match_id) group by bowler,season having innings > 6 order by economy_rate; 

-- CASES WHERE BOWLER DOT BALL % LESS THAN AVG DOT BALL % AT THAT VENUE