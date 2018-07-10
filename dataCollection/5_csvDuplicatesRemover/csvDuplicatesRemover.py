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

input_file_path = '../csvMerger/merged_28_04_2017.csv'

# the path to the file to be created containing the list of unique apps
filePath = 'new_merged_no_duplicates_' + '28_04_2017' +'.csv'

# DO NOT CHANGE ANYTHING BELOW THIS LINE

def checkPresence(key, seen):
    if key in seen:
        print(key)
        return True
    else:
        return False

with open(input_file_path,'r') as in_file, open(filePath,'w') as out_file:
    out_file.write('Repository,App,Source')
    seen = set()
    for line in in_file:
        # with this value of key, we are saying that identical apps have the same Google Play identifier
        key = line.split(',')[1]
        if checkPresence(key, seen): continue # skip duplicate
        seen.add(key)
        out_file.write(line)

print('Finished removing duplicates.')
