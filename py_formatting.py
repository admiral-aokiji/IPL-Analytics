import mysql.connector as msql
from dotenv import load_dotenv
import os

class Ball():
    def __init__(self,ball):
        self.ball_id = ball[0]
        self.match_id = ball[1]
        self.inning = ball[2]
        self.over = ball[3]
        self.ball = ball[4]
        self.batsman = ball[5]
        self.non_striker = ball[6]
        self.bowler = ball[7]
        self.wide_runs = ball[8]
        self.bye_runs = ball[9]
        self.legbye_runs = ball[10]
        self.noball_runs = ball[11]
        self.penalty_runs = ball[12]
        self.batsman_runs = ball[13]
        self.extra_runs = ball[14]
        self.total_runs = ball[15]
        self.player_dismissed = ball[16]
        self.dismissal_kind = ball[17]
        self.fielder = ball[18]
    

def checkStrike(pBall, cBall):
    # over change, caught or run out, single, triple, odd legbyes, odd byes, even wide runs, 4 also if overthrows (generate flags)
    pass


def checkWickets(cBall, nBall):
    batsmen = [nBall.batsman, nBall.non_striker]
    if (cBall.batsman not in batsmen) or (cBall.non_striker not in batsmen):
        if cBall.player_dismissed:
            return True
        else:
            print(f'player dismissal not recorded for {cBall.ball_id}')
            # Generate UPDATE query and append it to deliveries.sql ?
            return True


load_dotenv()
HOST = os.getenv('HOST')
PORT = os.getenv('PORT')
USER = os.getenv('USER')
PWD = os.getenv('PWD')
DB = os.getenv('DB')
mydb = msql.connect(
    host=HOST,
    port=PORT,
    user=USER,
    password=PWD,
    database=DB
)
mycursor = mydb.cursor()

# revert to orginal table after testing
db_sql = "SELECT * from deliveries2 limit 15;"
try:
    mycursor.execute(db_sql)
    balls = mycursor.fetchall()
except msql.Error as e:
    print(str(e))

# 
# check strike pe sahi banda according to runs
# check wicket fallen if batsman change suddenly
# striker_runs, striker_balls, non_striker_runs, non_striker_balls, team_runs, team_overs, actual ball? (can be extracted from team_overs)


print(vars(Ball(balls[0])))
miCombo = [0,0]
teamRuns = 0
teamOvers = 0.0
teamWickets = 0
bat1_runs = 0
bat1_balls = 0
bat2_runs = 0
bat2_balls = 0
bat1 = '-'
bat2 = '-'
dismiss_bat = '-'
dismiss_type = '-'
dismiss_fielder = '-'
dismiss_bowler = '-'
print(miCombo)
for i in range(len(balls)-1):
    
    # Check for innings change
    if miCombo != [Ball(balls[i]).match_id, Ball(balls[i]).inning]:
        print(f'miCombo changed at ballID - {Ball(balls[i]).ball_id} with {miCombo} ')
        miCombo = [Ball(balls[i]).match_id, Ball(balls[i]).inning]
        teamRuns = 0
        teamOvers = 0.0
        teamWickets = 0
        bat1_runs = 0
        bat1_balls = 0
        bat2_runs = 0
        bat2_balls = 0
        bat1 = Ball(balls[i]).batsman
        bat2 = Ball(balls[i]).non_striker
        dismiss_bat = '-'
        dismiss_type = '-'
        dismiss_fielder = '-'
        dismiss_bowler = '-'

    teamRuns += Ball(balls[i]).total_runs
    # check if delivery is legal
    if Ball(balls[i]).wide_runs == 0 and Ball(balls[i]).noball_runs == 0 and str(teamOvers)[-1] != '5':
        # check if wicket taken 
        # check who was dismissed and update 1. bat1 or bat2 attributes as 0, 2. update dismiss attributes. Dismissal ball will have +0.5 
        # change bat1 or 2 
        # check strike change and update
        teamOvers += 0.5
    elif Ball(balls[i]).wide_runs == 0 and Ball(balls[i]).noball_runs == 0 and str(teamOvers)[-1] == '6':
        # check if wicket taken
        # check who was dismissed and update 1. bat1 or bat2 attributes as 0, 2. update dismiss attributes. Dismissal ball will have +0.1
        # change bat1 or 2
        # check strike change and update
        teamOvers += 0.1
        bat1_balls += 1
    else: 
        # check if wicket taken
        # check who was dismissed and update 1. bat1 or bat2 attributes as 0, 2. update dismiss attributes. Dismissal ball will have no change in value i.e. previous value retained
        # change bat1 or 2
        # check strike change and update
        pass

    test1 = checkStrike(Ball(balls[i]),Ball(balls[i+1]))
    
    print(f'{Ball(balls[i]).ball_id} :- {teamRuns}/{teamWickets}  {teamOvers} || {bat1} ({bat1_runs},{bat1_balls}) | {bat2} ({bat2_runs},{bat2_balls})')
    # Add dismissal features

# iss hi file se match_batsman_scorecard mei daalne ka provision bana do but run na karo
