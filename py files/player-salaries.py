import pandas as pd
from selenium import webdriver
driver = webdriver.Firefox(executable_path='C:\\Program Files\\Mozilla Firefox\\geckodriver-v0.29.0-win64\\geckodriver.exe')
import json
import time

team_links = list()
for year in range(2008,2021):
    driver.get(f'https://moneyball.insidesport.co/teams.php?section={year}')
    team_links.extend([link.find_element_by_tag_name('a').get_attribute('href') for link in driver.find_elements_by_class_name('logo-team')])

def teamYearStats(link):
    driver.get(link)
    time.sleep(3)
    try:
        players = driver.find_elements_by_class_name('info-player')
        pl_list = list()
        for pl in players:
            player = dict()
            player['jersey_no'] = pl.find_element_by_class_name('number-player').text
            player['name'] = pl.find_element_by_tag_name('h4').find_element_by_tag_name('a').text.split('\n')[0].strip()
            player['role'] = pl.find_element_by_tag_name('h4').find_elements_by_tag_name('span')[0].text
            player['salary_rank'] = pl.find_element_by_tag_name('h4').find_elements_by_tag_name('span')[1].text.split(':')[1].strip()
            player['salary'] = pl.find_elements_by_tag_name('li')[1].text.split('\n')[1].strip()[2:]
            player['team'] = driver.find_element_by_tag_name('h1').text.title()
            player['season'] = link[-4:]
            pl_list.append(player)
        return pl_list
    except Exception as e:
        print('Error in scraping player details for-', str(e),link.split('?')[1])
        return None

output = list()
i = 0
for team in team_links:
    i += 1
    res = teamYearStats(team)
    if res:
        output.extend(res)
        print(i)

cols = list(output[0].keys())
df = pd.DataFrame(output, columns=cols)
df.to_csv('player_salaries.csv', index=True)
