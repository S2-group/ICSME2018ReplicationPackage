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

input_file_path = '../csvDuplicatesRemover/new_merged_no_duplicates_28_04_2017.csv'

# the path to the file to be created containing the list of apps and projects
filePath = 'new_final_' + '28_04_2017' +'.csv'

# DO NOT CHANGE ANYTHING BELOW THIS LINE

def checkManifest(key):
    # key = 'CorruptCube/Java-Barcode-Scanner-Server'

    print("KEY = ", key)

    url = 'http://github.com/search?utf8=%E2%9C%93&q=filename%3AAndroidManifest.xml+repo%3A' + key + '&type=Code&ref=searchresults'

    response, payload = httplib2.Http().request(url)
    error_list_occurrences = re.findall("find any code matching", payload.decode('utf-8'))
    return not error_list_occurrences

with open(input_file_path,'r') as in_file, open(filePath,'w') as out_file:
    out_file.write('Repository,App,Source\n')
    index = 0
    for line in in_file:
        index = index + 1
        if(index != 1):
            key = line.split(',')[0]
            print(str(index) + " - " + key)
            if not checkManifest(key):
                print("The above repository does not contain any Android manifest")
                continue # skip app without Android manifest
            out_file.write(line)

print('Finished checking.')
