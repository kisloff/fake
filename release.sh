#!/bin/bash

# THe issue is that the Maven Release Plugin insists on creating a tag, and git-flow also wants to create a tag.
# Secondly, the Maven Release Plugin updates the version number to the next SNAPSHOT release before you can
# merge the changes into master, so you end with the SNAPSHOT version number in master, and this is highly undesired.
# This script solves this by doing changes locally, only pushing at the end.
# All git commands are fully automated, without requiring any user input.
# See the required configuration options for the Maven Release Plugin to avoid unwanted pushs.

# Based on the excellent information found here: http://vincent.demeester.fr/2012/07/maven-release-gitflow/

git checkout develop

#take project version from pom
echo 'Version resolving started'
prevProjectVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`
echo prevProjectVersion=$prevProjectVersion

mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion} versions:commit | grep -v '\['
releaseVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`
echo releaseVersion=$releaseVersion

mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}-SNAPSHOT versions:commit | grep -v '\['
developmentVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`
echo developmentVersion=$developmentVersion

git checkout pom.xml

#mvn build-helper:parse-version versions:set -DnewVersion=$releaseVersion versions:commit | grep -v '\['
#echo releaseVersion=`mvn -o org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\['`

# The version to be released
#releaseVersion=1.0.11
# The next development version
#developmentVersion=1.0.12-SNAPSHOT
# Provide an optional comment prefix, e.g. for your bug tracking system
scmCommentPrefix='Release maker: '

if git rev-parse --verify release/$releaseVersion; then echo 'branch exists. deleting' |  git branch -D release/$releaseVersion; else echo 'branch does not exist. creating'; fi

# Start the release by creating a new release branch
git checkout -b release/$releaseVersion develop

# The Maven release
mvn --batch-mode release:prepare release:perform -DscmCommentPrefix="$scmCommentPrefix" -DreleaseVersion=$releaseVersion -DdevelopmentVersion=$developmentVersion

# Clean up and finish
# get back to the develop branch
git checkout develop

# merge the version back into develop
git merge --no-ff -m "$scmCommentPrefix Merge release/$releaseVersion into develop" release/$releaseVersion
# go to the master branch
git checkout master
# merge the version back into master but use the tagged version instead of the release/$releaseVersion HEAD
git merge --no-ff -m "$scmCommentPrefix Merge previous version into master to avoid the increased version number" release/$releaseVersion~1
# Removing the release branch --switched off
#git branch -D release/$releaseVersion
# Get back on the develop branch
git checkout develop
# Finally push everything
git push --all && git push --tags