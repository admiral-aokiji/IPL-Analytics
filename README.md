# IPL Analytics Project - Analyzing the miracles, fails and scams of the Indian Premier League

### This project uses the <a href='/https://www.kaggle.com/nowke9/ipldata'>IPL dataset -1</a> and <a href='/https://www.kaggle.com/nowke9/ipldata'>IPL dataset -2</a> from Kaggle that contains ball-by-ball data for each match of the first 12 IPLs. ___All the data cleaning, wrangling and EDA has been done solely using SQL___ and will be visualized in the future using Power BI (or whichever BI tool that interests me then)

Features that may/will be worked upon in the future:
- Tutorial on loading the dataset from an AWS S3 instance and then feeding the data into an AWS Redshift instance
- Adding relationships between the tables

Errors remaining:
- runs_on_dismissal and runs_on_arrival do not match because of addition of runs on the 1st ball a new batsman faces

CHANGES COMPLETED BEFORE COMMITTING
1. Match id sorted order
2. Deliveries match_id corrected according to changes
3. matches table design redefined
4. Load 2020 matches from new_matches.csv
5. Tosses won in points table corrected