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

input_file_path = '../into_page_checker.csv'

# the path to the file to be created containing the list of apps and projects
filePath = 'additional_final_playchecked_' + '28_04_2017' +'.csv'

# DO NOT CHANGE ANYTHING BELOW THIS LINE

def checkGooglePlayPage(key):
    # key = 'CorruptCube/Java-Barcode-Scanner-Server'
    url = 'http://play.google.com/store/apps/details?id=' + key

    response, payload = httplib2.Http().request(url)
    error_list_occurrences = re.findall("We're sorry, the requested URL was not found on this server", payload.decode('utf-8'))
    return not error_list_occurrences

with open(input_file_path,'r') as in_file, open(filePath,'w') as out_file:
    out_file.write('Repository,App,Source\n')
    index = 0
    for line in in_file:
        index = index + 1
        if(index != 1):
            key = line.split(',')[1]
            print(str(index) + " - " + key)
            if not checkGooglePlayPage(key):
                print("The above app does not exist in Google Play anymore")
                continue # skip app without Google Play page
            out_file.write(line)

print('Finished filtering.')
