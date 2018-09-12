#!/bin/bash
# The script clones all public repositories of an GitHub user.

GITHUB_USER=khalido

# the git clone cmd used for cloning each repository
# the parameter recursive is used to clone submodules, too.
GIT_CLONE_CMD="git clone "

# getting list of public repos
echo "fetching repository list via github api for $GITHUB_USER"
REPOLIST=`curl -s "https://api.github.com/users/$GITHUB_USER/repos?per_page=1000" | grep -w clone_url | grep -o '[^"]\+://.\+.git'`

# loop over all repository urls and execute clone
for REPO in $REPOLIST; do
    #echo "cloning $REPO"
    ${GIT_CLONE_CMD}${REPO}
done

echo "all public repos cloned"

# run this on the cli to get a list of clone urls
# GHUSER=khalido; curl -s "https://api.github.com/users/$GHUSER/repos?per_page=1000" | grep -w clone_url | grep -o '[^"]\+://.\+.git'