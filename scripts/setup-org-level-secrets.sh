#!/bin/bash

set -e


# https://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# require positional argument
if [[ $# -ne 1 ]]; then
  echo "usage: $0 org" >&2
  exit 1
fi
# require authentication
gh auth status


ORG="$1"
REPO="org-level-secrets"
LOCAL_REPO="$(mktemp -d)"


gh secret set "MYSECRET" --body "1234567890" --org "$ORG" --visibility "all"

cd "$LOCAL_REPO"
git init
echo "$REPO" > "README.md"
mkdir -p ".github/workflows"
cat << "EOF" > ".github/workflows/ci.yml"
name: CI

on:
  pull_request_target:

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - run: npm install
      - run: npm test
EOF
cat << "EOF" > "package.json"
{
  "name": "test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
EOF
git add -A
git commit -m "Initial commit"

# https://github.com/cli/cli/issues/3796#issuecomment-1065150465
git -C "$LOCAL_REPO" config "credential.https://github.com.helper" ""
git -C "$LOCAL_REPO" config --add "credential.https://github.com.helper" "!/usr/local/bin/gh auth git-credential"
gh repo create "$ORG/$REPO" --public --source "$LOCAL_REPO" --push