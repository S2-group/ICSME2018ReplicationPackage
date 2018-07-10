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

input_file_path = './with_app_root_28_04_2017.csv'

# the path to the file to be created containing the list of apps and projects
filePath = 'with_app_root_filtered_' + '28_04_2017' +'.csv'

# DO NOT CHANGE ANYTHING BELOW THIS LINE

rows = []

f = open(filePath, 'w')

writer = csv.writer(f)

with open(input_file_path,'r') as input_file:
    for line in input_file:
        current_app_root = line.rstrip().split(",")[4]

        if(current_app_root == 'na'): continue

        current_repo = line.rstrip().split(",")[0]
        current_googleplay = line.rstrip().split(",")[1]
        current_source = line.rstrip().split(",")[2]
        current_commits = line.rstrip().split(",")[3]
        rows.append([current_repo, current_googleplay, current_source, current_commits, current_app_root])

    writer.writerows(rows)

print('Finished adding.')
