# -*- coding: utf-8 -*-

import csv 
import os
import subprocess
import re
from datetime import datetime

input_list_of_apps = 'tst.csv'

def get_datetime(ts):
	return str(datetime.fromtimestamp(ts))

def check_repo_exists(github_url):
	try:
		res = subprocess.check_output(["git", "ls-remote", str(github_url)], stderr=subprocess.STDOUT)
		return res
	except subprocess.CalledProcessError, e:
		return str(e.output)

def clone_repo(github_url, timestamp):
	
	snapshot_dir = re.compile("https://github.com/.*/").split(github_url)[1].replace(".git", "") + "_" + str(timestamp)

	try:
		subprocess.call(["git", "clone", github_url, snapshot_dir])
		os.chdir(snapshot_dir)

		snapshot_date = get_datetime(timestamp)
		checkout_sha = subprocess.check_output(["git", "rev-list", "-n", "1", "--before='" + snapshot_date + "'", "master"]).rstrip()
		result = subprocess.call(["git", "checkout", "-q", checkout_sha])

		os.chdir("../")
		
		return snapshot_dir

	except:
		print("Error during clone/checkout.")
		return -1


def delete_snapshot_folder(snapshot_dir):
	try:
		shutil.rmtree(snapshot_dir)
		print("Snapshot " + snapshot_dir + " deleted.")
	except OSError: 
		raise

processed_apps = 0
with open(input_list_of_apps) as input:
	
	header = next(input) #save col names, skip first row
	for app in input:
		
		values = app.split(",")
		repo_link = "https://github.com/" + values[0] + ".git"
		
		result = check_repo_exists(repo_link)
		if (result == 128 or "fatal" in result):
			continue
		else:
			processed_apps = processed_apps + 1

		end_ts = int(values[5])
		snap_dir = clone_repo(repo_link, end_ts)

print("Finished. Processed apps = " + str(processed_apps))