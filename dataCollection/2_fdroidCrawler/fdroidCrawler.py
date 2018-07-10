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

# the page from which to start crawling
page_index = 1

# the path to the file to be created containing the list of apps and projects
filePath = 'fdroid_' + '11_02_2016' +'.csv'

# DO NOT CHANGE ANYTHING BELOW THIS LINE

# the url fragment representing the search on F-Droid
url_fragment = 'https://f-droid.org/forums/search/play.google.com+github.com/page/'

rows = []

f = open(filePath, 'w')
rows.append(['Repository', 'App'])

writer = csv.writer(f)
writer.writerows(rows)

url = url_fragment + "1"

response, payload = httplib2.Http().request(url)
rootHtml = lxml.html.fromstring(payload)
num_pages = rootHtml.cssselect('.page-numbers')
num_pages = int(num_pages[len(num_pages) - 2].text)

#num_pages = 1

while(page_index <= num_pages):
    url = url_fragment + str(page_index)

    rows = []

    response, payload = httplib2.Http().request(url)
    rootHtml = lxml.html.fromstring(payload)
    elements = rootHtml.cssselect('.bbp-topic-content')

    if len(elements) != 0:
        for elem in elements:
            try:
                # here we take the first link matching the string "://github.com"
                current_repo = elem.cssselect('a[href*="://github.com/"]')[0].get('href')
                current_repo = re.findall("http[s]?://github.com/[^/]+/[^/^&^#]+", current_repo)[0].encode('utf-8')

                print(current_repo)

                current_googleplay = elem.cssselect('a[href*="://play.google.com/store/apps/details"]')[0].get('href')
                current_googleplay = re.findall("http[s]?://play.google.com/store/apps/details\?id=[^&^#]+", current_googleplay)[0].encode('utf-8')

                rows.append([current_repo + ".git", current_googleplay])
            except:
                print("Error")
        writer.writerows(rows)
        print('Fetched GitHub page: ' + str(page_index))
    else:
        print("Error while fetching page: " + str(page_index))
    page_index = page_index + 1

print('Finished fetching.')
