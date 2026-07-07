# -*- coding: utf-8 -*-
"""
Created on Tue Jan  6 21:46:46 2026

@author: Anthony

Use web scraping to extract product name and price into csv daily
"""

from bs4 import BeautifulSoup
import requests
import smtplib # Send emails to yourself
import time
import datetime

import re

# Create csv to add data and automate it
import csv

def check_price(make_header=False):
    # Connect to website
    URL = 'https://www.jumbo.com/producten/unox-soep-tomaat-creme-570ml-300830ZK'

    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

    page = requests.get(URL, headers=headers)

    soup1 = BeautifulSoup(page.content, 'html.parser')
    soup2 = BeautifulSoup(soup1.prettify(), 'html.parser')


    title = soup2.select_one('[data-testid="product-title"]').get_text()
    price = soup2.find('div', {'class': 'screenreader-only'}).get_text()

    title = title.strip()
    price = re.findall("\d+\,\d+", price)[0]
    
    # Time stamp
    today = datetime.date.today()
    
    header = ['Title', 'Price', 'Date']
    data = [title, price, today]
    
    if make_header == True:
        with open('JumboWebScraperDataset.csv', 'w', newline='', encoding='UTF8') as f:
            writer = csv.writer(f)
            writer.writerow(header)
    
    with open('JumboWebScraperDataset.csv', 'a+', newline='', encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)

while(True):
    check_price()
    time.sleep(86400)
#%%
# Visualize table
import pandas as pd

df = pd.read_csv('JumboWebScraperDataset.csv')
print(df)