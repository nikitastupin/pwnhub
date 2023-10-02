#!/usr/bin/env bash

set -e

readonly TEST_YML="$(mktemp)"

cat > "$TEST_YML" << "EOF"
on:
  pull_request_review:
  pull_request_review_comment:

permissions: write-all

jobs:
  main:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Hello, world!"
EOF

readonly OWNER="$(gh api user --jq .login)"
readonly REPO='pull-request-review'

gh repo delete "$REPO" || echo "$REPO does not exist"
gh repo create --public "$REPO"

gh api --silent \
  -X PUT \
  "/repos/$OWNER/$REPO/contents/.github/workflows/test.yml" \
  -f message='init' \
  -f content="$(cat "$TEST_YML" | base64)"

gh api --silent \
  --method POST \
  -H "Accept: application/vnd.github.v3+json" \
  "/repos/$OWNER/$REPO/git/refs" \
  -f ref='refs/heads/add-readme' \
  -f sha="$(gh api repos/nshackerone/pull-request-review/git/ref/heads/main --jq .object.sha)"

gh api --silent \
  -X PUT "/repos/$OWNER/$REPO/contents/README.md" \
  -f branch=add-readme \
  -f message='add README.md' \
  -f content="$(echo '123' | base64)"

gh pr create --repo "$OWNER/$REPO" --head add-readme --base main --title test --body ''
