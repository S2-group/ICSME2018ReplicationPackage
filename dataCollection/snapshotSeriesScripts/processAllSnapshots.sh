#!/bin/bash

if [ $# != 2 ] 
then
   echo Wrong usage! Format: ./main_script csvfile.csv commitfrequency_in_seconds
   exit
fi

#Setting verbose mode to help debugging
#set -xv

processedRepos=0
failedRepos=0
scriptLogFileName=script_log.txt
commitInfoFileName=commit_info_full.txt
commitInfoMetadata=commit_info_metadata.txt
gradleProjectsFileName=gradle_projects.txt

function extract_commit_metadata() {

	sha=$(git rev-parse --verify HEAD)
	dateHuman=$(git show -s --format="%ci" $sha)
	dateUnix=$(git show -s --format="%ct" $sha)
	message=$(git log -1 --pretty=%B)
	author=$(git show -s --format="%an <%ae>" $sha)
	
	echo $1, $sha, $dateHuman, $dateUnix, $message, $author >> /legacy/$commitInfoMetadata
}

function checkout_repository() {
	
	# IMPORTANT: Linux and MacOS have diff interpretations of date command, see below
	#use this on MacOs
	#dateFname=$(date -r $1 +"%Y-%m-%d_%H-%M-%S")
	#dateCommit=$(date -r $1 +"%Y-%m-%d %H:%M:%S")

	#use this on Linux
	dateFname=$(date -d @$1 +"%Y%m%d")
	dateCommit=$(date -d @$1 +"%Y-%m-%d %H:%M:%S")

	snapshotDir=$applicationGitDir-$dateFname

	# redirecting output so we only see errors on the screen
	git clone $gitLink $applicationGitDir/$snapshotDir 1> /dev/null 
	cd $applicationGitDir/$snapshotDir	
	
	#checkout repo at snapshot date
  	git checkout `git rev-list -n 1 --before="$dateCommit" master` 

	extract_commit_metadata $snapshotDir

	#extracting all commit information
	if [[ $1 -eq $endTs  ]] ; then
		echo "Commit info for repo: $applicationGitDir" >> ../../$commitInfoFileName
		git -C . log >> ../../$commitInfoFileName		
	fi

	echo "$1) Done with the snapshot checkout, deleting snapshot dir and returning to main folder..." >> ../../$scriptLogFileName

 	cd ../../
	
}

function check_if_repo_exists() {
	((processedRepos++))

	if git ls-remote $1 ; then	
		echo "Repository $1 OK" >> $scriptLogFileName
		mkdir $repoDir$applicationGitDir
		return 0
	else
    		echo "Repository $1 FAIL" >> $scriptLogFileName 
		((failedRepos++))
		return 1
	fi
}


function is_gradle_project() {
	isGradle="no"
	
        if [[ $(find $1 -name '*build.gradle' | wc -l) -gt 0 ]] ; then
                isGradle="yes"
	fi
	echo $applicationGitDir,$isGradle >> $gradleProjectsFileName 
}

function extract_manifest_file() {
	find $1 -name "*AndroidManifest.xml*" -exec cp {} MANIFESTS/$1_AndroidManifest.xml \; | tail -n 1		
}

i=1
while IFS=, read repo app source commits startTs endTs diffTs diffInWeeks 
do

	#skip first line
	test $i -eq 1 && ((i=i+1)) && continue

	applicationGitDir=$(basename $repo)	
	gitLink=https://github.com/$repo
	
	appNameForScope=$(echo "$applicationGitDir" | tr -d -)
	
	if check_if_repo_exists $gitLink ; then 
			
		while [ $startTs -lt $endTs ]
		do
			checkout_repository $startTs
        		let "startTs += $2"
		done
		
		#checkout once more to make sure end timestamp got checked out
		checkout_repository $endTs

		is_gradle_project $applicationGitDir
		extract_manifest_file $applicationGitDir

		#insert static code analysis tool command here

		echo "** appDir to be removed = $applicationGitDir ***" >> $scriptLogFileName    
		rm -rf $applicationGitDir 
	fi
	
done < $1

echo "$(date) - Total Processed / Failed repositories: $processedRepos / $failedRepos" >> $scriptLogFileName 
