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

input_file_path = '../numberCommitsAdder/fdroid_with_number_commits_28_04_2017.csv'

# the path to the file to be created containing the list of apps and projects
filePath = 'fdroid_with_app_root_' + '28_04_2017' +'.csv'

# DO NOT CHANGE ANYTHING BELOW THIS LINE

rows = []

f = open(filePath, 'a')

writer = csv.writer(f)
writer.writerows(rows)
index = 0
startingIndex = 0

if(startingIndex == 0):
    rows.append(['Repository', 'App', 'Source', 'Commits', 'AppFolder'])

with open(input_file_path,'r') as input_file:
    for line in input_file:
        if(index != 0 and index >= startingIndex):
            rows = []
            waitingTime = random.randrange(1, 3)
            #try:
            current_repo = line.rstrip().split(",")[0]
            current_googleplay = line.rstrip().split(",")[1]
            current_source = line.rstrip().split(",")[2]
            current_commits = line.rstrip().split(",")[3]
            url = 'http://github.com/search?utf8=%E2%9C%93&q=filename%3AAndroidManifest.xml+repo%3A' + current_repo + '&type=Code&ref=searchresults'

            responseStatus = 429
            while(responseStatus != 200):
                try:
                    time.sleep(waitingTime)
                    response, payload = httplib2.Http().request(url)
                    print("retrying for: " + current_repo)
                    responseStatus = response.status
                except (KeyboardInterrupt, SystemExit):
                    raise
                except:
                    print("Exception occurred")

            rootHtml = lxml.html.fromstring(payload)
            elements = rootHtml.cssselect('.full-path a')
            app_folder = 'na'
            for el in elements:
                if el.get('href').endswith('AndroidManifest.xml'):
                    if el.text:
                        app_folder = el.text
                    else:
                        app_folder = '/'
            print(str(index) + " - " + url + " - " + app_folder)
            # except:
            #     print(str(index) + " - ERROR for: " + url)
            #     app_folder = "na"

            print("Sleeping for " + str(waitingTime) + " seconds")
            time.sleep(waitingTime)
            rows.append([current_repo, current_googleplay, current_source, current_commits, app_folder])
            writer.writerows(rows)
            f.close()
            f = open(filePath, 'a')
            writer = csv.writer(f)
        index = index + 1

print('Finished adding.')
