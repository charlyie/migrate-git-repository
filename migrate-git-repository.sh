#!/bin/bash
# Adapted from: http://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches and from https://www.atlassian.com/git/tutorials/git-move-repository

TEMP_FOLDER="/tmp/migrate-git-temp-folder"

printf "GIT Sync repositories\n"

read -p "[>] Provide original GIT Repo : " OLD_GIT_REPO
read -p "[>] Provide new GIT Repo : " NEW_GIT_REPO

while [ "$USE_CONTAINER" != "y" ] && [ "$USE_CONTAINER" != "n" ]; do 
    printf "\nYou're about to clone GIT repo ${OLD_GIT_REPO} to the new repo ${NEW_GIT_REPO} \n"
    read -p "Do you want to continue ? (y/n) : " USE_CONTAINER
done

printf "[>] Purging previous temporary folder...\n"
if [ -d "$TEMP_FOLDER" ]; then rm -Rf $TEMP_FOLDER; fi

printf "[>] Cloning repository...\n"
git clone $OLD_GIT_REPO $TEMP_FOLDER
cd $TEMP_FOLDER

printf "[>] Fetching all branches...\n"
for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master`; do
    git branch --track ${branch##*/} $branch
done
git fetch --all
git pull --all

printf "[>] List of fetched tags :\n"
git tag
printf "[>] List of fetched branches :\n"
git branch -a
printf "[>] Removing link to the previous GIT Repo Host...\n"
git remote rm origin

printf "[>] Linking to new repository...\n"
git remote add origin $NEW_GIT_REPO

printf "[>] Pushing data...\n"
git push origin --all
git push --tags

printf "[>] Migration achieved successfully!\n"
cd -