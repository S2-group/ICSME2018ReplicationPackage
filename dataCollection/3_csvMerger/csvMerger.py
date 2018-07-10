import httplib2
import lxml
from lxml import etree
from lxml import html
import cssselect
import csv
import time
import math
import random
import re

github_file_path = '../MERGED_outputs.csv'
wikipedia_file_path = '../Wikipedia_Repos_28_04_2017 - Sheet1.csv'
froid_file_path = '../fdroid_28_04_2017.csv'

# the path to the file to be created containing the list of apps and projects
filePath = 'merged_' + '28_04_2017' +'.csv'

# DO NOT CHANGE ANYTHING BELOW THIS LINE

f = open(filePath, 'w')
rows = []

writer = csv.writer(f)
rows.append(['Repository', 'App', 'Source'])
writer.writerows(rows)

current_repo = ''
current_googleplay = ''

def copyFileContents(file, sourceType, writer):
    index = 0
    rows = []
    for line in file:
        if(index != 0):
            try:
                current_line = line.rstrip() + ',' + sourceType
                current_line = current_line.replace('http://github.com/', '')
                current_line = current_line.replace('http://play.google.com/store/apps/details?id=', '')
                print(current_line)

                rows.append(current_line.split(','))
            except:
                print(str(index) + ' - ERROR for: ' + current_line)
        index = index + 1
    writer.writerows(rows)

with open(github_file_path,'r') as github_file, open(wikipedia_file_path,'r') as wikipedia_file, open(froid_file_path,'r') as fdroid_file:
    copyFileContents(github_file, 'G',writer)
    copyFileContents(wikipedia_file, 'W',writer)
    copyFileContents(fdroid_file, 'F',writer)

print('Finished merging.')
