# coding: utf-8

import httplib2
import lxml
from lxml import etree
from lxml import html
import cssselect
import csv
import time
import math
import random

# the ranges of dates to search
dates = ['\"2017-03-15+..+2017-04-27\"',
'\"2016-10-26+..+2017-03-14\"','\"2016-05-28+..+2016-10-25\"',
'\"2016-01-03+..+2016-05-27\"','\"2015-07-20+..+2016-01-02\"',
'\"2015-01-25+..+2015-07-19\"','\"2014-06-18+..+2015-01-24\"',
'\"2013-09-15+..+2014-06-17\"','\"2011-02-15+..+2013-09-14\"',
'\"2001-01-01+..+2011-02-14\"'] 


# the number of search results on GitHub (all these numbers must be below 1000)
# remember to change this to the actual number of results of the real search on the github.com website
# TEST LINK BELOW:
# https://github.com/search?utf8=✓&q=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3D+in%3Areadme+created%3A%222017-03-15..2017-04-27%22&type=Repositories&ref=searchresults
dates_num_results = [979, 996, 994, 997, 999, 997, 983, 982, 996, 27]
# the index of the page from which we want to start the search
dates_start_index = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

# DO NOT CHANGE ANYTHING BELOW THIS LINE

url_fragment_1 = 'https://github.com/search?p='
url_fragment_2 = '&q=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3D+in%3Areadme+created%3A'
url_fragment_3 = '&ref=searchresults&type=Repositories&utf8=%E2%9C%93'

for dates_index, current_date in enumerate(dates):
    print('Fetching for dates: ' + current_date)
    filePath = 'repos' + str(dates_index) + '.csv'

    page_index = dates_start_index[dates_index]
    to_page_index = math.ceil(dates_num_results[dates_index] / 10.0)

    print("Page index =", page_index, ", to_page=", to_page_index)

    rows = []
    append = True

    if(append):
        f = open(filePath, 'a')
    else:
        f = open(filePath, 'w')
        rows = [['Repository']]

    writer = csv.writer(f)

    while(page_index <= to_page_index):
        waitingTime = random.randrange(1, 10)
        url = url_fragment_1 + str(page_index) + url_fragment_2 + current_date + url_fragment_3
        response, payload = httplib2.Http().request(url)
        rootHtml = lxml.html.fromstring(payload)

        #elements = rootHtml.cssselect('.repo-list-name a')
        #elements = rootHtml.cssselect('.repo-list-item a')
        elements = rootHtml.cssselect('.repo-list h3 a') # changed from repo-list-name to repo-list and added h3 tag

        rows = []
        if len(elements) != 0:
            for elem in elements:
                rows.append([elem.text])
            writer.writerows(rows)
            print('Fetched GitHub page: ' + str(page_index))
            page_index = page_index + 1
        else:
            print("Error while fetching page: " + str(page_index))
        print("Sleeping for " + str(waitingTime) + " seconds")
        time.sleep(waitingTime)
    print('Finished to fetch for dates: ' + current_date)
print('Finished fetching.')
