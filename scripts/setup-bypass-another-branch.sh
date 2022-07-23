#!/bin/bash

set -e


# https://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/lib/boilerplate.sh"

# require authentication
gh auth status


OWNER="$(gh api '/user' --jq '.login')"
REPO="bypass-another-branch"
LOCAL_REPO="$(mktemp -d)"

cd "$LOCAL_REPO"
git init -b "main"
echo "$REPO" > "README.md"
# 1. A workflow with the Pwn Request vulnerability is committed to the default branch of a repository.
boilerplate_pull_request_target
git add -A
git commit -m "Initial commit"
# 2. Maintainers create new branches from the default branch. In this way vulnerability propogates to another branches.
git checkout -b feature
# 3. The vulnerability gets fixed in the default branch.
git checkout main
boilerplate_pull_request
git commit -am "Fix vulnerability"

# https://github.com/cli/cli/issues/3796#issuecomment-1065150465
git -C "$LOCAL_REPO" config "credential.https://github.com.helper" ""
git -C "$LOCAL_REPO" config --add "credential.https://github.com.helper" "!/usr/local/bin/gh auth git-credential"
gh repo create "$OWNER/$REPO" --public --source "$LOCAL_REPO" --push
git checkout feature
git push --set-upstream origin feature