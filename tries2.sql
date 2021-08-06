select distinct match_id from deliveries where fielder = 'AS Yadav' or batsman = 'AS Yadav';
select * from matches where match_id = 423;
select * from super_over_balls;
select * from matches where date = "2012-05-20";
start transaction;
commit;
rollback;

    
create table match_batsman_scorecards like match_batsman_scorecards2;
drop table match_batsman_scorecards;

with cte as 
(SELECT match_id, batsman as player from match_batsman_scorecards where inning = 1 union
SELECT match_id, fielder as player from match_batsman_scorecards where inning = 2 and fielder is NOT null and fielder not like '%(sub)%' group by match_id, fielder union
SELECT match_id, bowler as player from match_batsman_scorecards where inning = 2 and bowler not in ('NO', 'DNB') group by match_id, bowler)
select match_id, player as squad from cte where match_id = 807; 

SELECT * from match_batsman_scorecards2 where match_id in (22,152,317);
delete from match_batsman_scorecards;


