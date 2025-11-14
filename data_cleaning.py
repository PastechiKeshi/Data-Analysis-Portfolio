# -*- coding: utf-8 -*-
"""
Created on Sun Oct 26 18:38:40 2025

@author: Anthony
"""

import pandas as pd

df = pd.read_excel('excel files/Customer Call List.xlsx')
df.set_index('CustomerID',inplace=True)

'''
Removing duplicates
'''

df.drop_duplicates(inplace=True)

'''
Removing columns
'''

df.drop(columns = 'Not_Useful_Column', inplace=True)

'''
Strip
'''

df['Last_Name'] = df['Last_Name'].str.strip('/._ ')

'''
Clean/standardizing phone numbers
'''

df['Phone_Number'] = df['Phone_Number'].apply(lambda x: str(x))

df['Phone_Number'] = df['Phone_Number'].str.replace('[^0-9]','',regex=True)

df['Phone_Number'] = df['Phone_Number'].apply(
    lambda x: x[0:3]+'-'+x[3:6]+'-'+x[6:] if len(x) > 0 else '')

'''
Splitting columns
'''

df[['Street_Address','State','Zip_Code']] = df['Address'].str.split(',',n=2,expand=True)

df.drop(columns = 'Address', inplace=True)

'''
Standardizing column values
'''
col_list = ['Paying Customer','Do_Not_Contact']
df[col_list] = df[col_list].replace('Yes','Y',regex=True)
df[col_list] = df[col_list].replace('No','N',regex=True)

'''
Filling null values
'''

df.replace('N/a','',inplace=True)
df.fillna('',inplace=True)

'''
Filtering Down Rows of Data
'''

for x in df.index:
    if df.loc[x,'Do_Not_Contact'] == 'Y' or df.loc[x,'Phone_Number'] == '':
        df.drop(x,inplace=True)

'''
Export to Excel file
'''

df.to_excel('Refined Call List.xlsx')