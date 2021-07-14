import mysql.connector as msql
from dotenv import load_dotenv
import os
import logging
# import time

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
        self.player_dismissed = ball[16] if ball[16] else ''
        self.dismissal_kind = ball[17] if ball[17] else ''
        self.fielder = ball[18] if ball[18] else ''
        self.batsmen = (ball[5],ball[6])
    

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
logging.basicConfig(level = logging.INFO, filename='app.log', format=f' %(message)s')


def updateDeliveries(startID):

    db_sql = f"SELECT * from deliveries2 where match_id = {startID}  ;"
    try:
        mycursor.execute(db_sql)
        balls = mycursor.fetchall()
    except msql.Error as e:
        logging.exception("Exception occurred")

    miCombo = [0, 0]
    teamRuns = 0
    teamOvers = 0.0
    teamWickets = 0
    batsmen = [{
        'id': 1,
        'runs': 0,
        'balls': 0,
        'name':'-'
    },{
        'id': 2,
        'runs': 0,
        'balls': 0,
        'name':'-'
    }] 

    def checkWickets(cBall, nBall,batsman):
        if (nBall.inning != cBall.inning):
            logging.warning('Yes')
        nonlocal teamWickets, wicket_string
        teamWickets += 1
        wicket_string = ' || W ' + batsman['name'] + ' (' + str(batsman['runs']) + ','+str(batsman['balls'])+') ' + cBall.dismissal_kind + ' ' + cBall.fielder + 'b ' + cBall.bowler
        other_batsman = [bat for bat in batsmen if batsman['id'] != bat['id']]
        if other_batsman[0]['name'] == nBall.batsman and (teamOvers*10)%10 != 0:
            batsman['name'] = nBall.non_striker
        elif other_batsman[0]['name'] == nBall.batsman and (teamOvers*10) % 10 == 0:
            batsman['name'] = nBall.batsman
        elif other_batsman[0] == nBall.non_striker and (teamOvers*10) % 10 != 0:
            batsman['name'] = nBall.non_striker
        else:
            batsman['name'] = nBall.batsman
        batsman['runs'] = 0
        batsman['balls'] = 0
        if not cBall.player_dismissed and (nBall.inning == cBall.inning):
            logging.warning(f'player dismissal not recorded for {cBall.ball_id}')
            # Generate UPDATE query and append it to deliveries.sql ?
            # update deliveries set player_dismissed = X where ball_id = X;

    for i in range(len(balls)-1):
        
        wicket_string, bye_string, legbye_string = '', '', ''
        cBall = Ball(balls[i])
        nBall = Ball(balls[i+1])
        
        # Checking for innings change
        if miCombo != [cBall.match_id, cBall.inning]:
            miCombo = [cBall.match_id, cBall.inning]
            logging.info(f'miCombo changed at ballID - {cBall.ball_id} with {miCombo}')
            for bat in batsmen:
                bat['runs'] = 0
                bat['balls'] = 0
            teamRuns, teamOvers, teamWickets, batsmen[0]['name'], batsmen[1]['name'] = 0, 0.0, 0, cBall.batsman, cBall.non_striker
            # time.sleep(3)
        
        if batsmen[0]['name'] == batsmen[1]['name']:
            logging.error(f'Both batsmen same at {teamOvers} ')
            break

        # Changing batsman on strike
        if cBall.batsman != batsmen[0]['name']:
            for key in batsmen[0]:
                batsmen[0][key], batsmen[1][key] = batsmen[1][key], batsmen[0][key]

        teamRuns += cBall.total_runs
        batsmen[0]['runs'] += cBall.batsman_runs

        # checking for legal deliveries
        if cBall.wide_runs == 0 and cBall.noball_runs == 0:

            # Updating teamOvers and checking for over change
            if str(teamOvers)[-1] == '5':
                teamOvers += 0.5
            else:
                teamOvers += 0.1
            teamOvers = round(teamOvers, 1)
            batsmen[0]['balls'] += 1

            if (cBall.batsman not in nBall.batsmen):
                checkWickets(cBall,nBall,batsmen[0])
                
            elif (cBall.non_striker not in nBall.batsmen):
                checkWickets(cBall, nBall, batsmen[1])

            if cBall.legbye_runs != 0 :
                legbye_string = ' Legbyes ' + str(cBall.legbye_runs)
            elif cBall.bye_runs != 0:
                bye_string = ' Byes ' + str(cBall.bye_runs)
            ball_string = f"{cBall.match_id}|{cBall.inning} - {cBall.ball_id} :- {teamRuns}/{teamWickets}  {teamOvers} ||{batsmen[0]['name']} ({batsmen[0]['runs']},{batsmen[0]['balls']}) | {batsmen[1]['name']} ({batsmen[1]['runs']},{batsmen[1]['balls']})|| {cBall.total_runs}"
            logging.info(ball_string + bye_string + legbye_string + wicket_string)

        else: 
            if (cBall.batsman not in nBall.batsmen) and (nBall.inning == cBall.inning):
                checkWickets(cBall, nBall,batsmen[0])

            elif (cBall.non_striker not in nBall.batsmen):
                checkWickets(cBall, nBall,batsmen[1])
            ball_string = f"{cBall.match_id}|{cBall.inning} - {cBall.ball_id} :- {teamRuns}/{teamWickets}  {teamOvers} ||{batsmen[0]['name']} ({batsmen[0]['runs']},{batsmen[0]['balls']}) | {batsmen[1]['name']} ({batsmen[1]['runs']},{batsmen[1]['balls']})  || {cBall.total_runs} Extras - {cBall.extra_runs}"
            logging.info(ball_string + bye_string + legbye_string + wicket_string)
    # iss hi file se match_batsman_scorecard mei daalne ka provision bana do but run na karo


updateDeliveries(7949)
