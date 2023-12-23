#!/usr/bin/env bash

set -e

readonly BUILD_FORK_YML="$(mktemp)"
readonly DEPLOY_FORK_YML="$(mktemp)"

cat > "$BUILD_FORK_YML" << "EOF"
name: Build Fork

on:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    if: | # check if PR opened from fork
      github.event.pull_request.head.repo.full_name != github.event.pull_request.base.repo.full_name
    steps:
      # ...
      # building steps
      # ...
      - name: Save PR number
        run: |
          mkdir -p ./__pr
          echo ${{ github.event.number }} > ./__pr/NUM
      - name: Store PR info 
        uses: actions/upload-artifact@6673cd052c4cd6fcf4b4e6e60ea986c889389535 # v3.0.0
        with:
          name: pr
          path: __pr/
      # ...
      # remaining steps
      # ...
EOF

cat > "$DEPLOY_FORK_YML" << "EOF"
name: Deploy Fork

on:
  workflow_run:
    workflows: [Build Fork]
    types:
      - completed

permissions: write-all

jobs:
  prepare_jobs:
    runs-on: ubuntu-latest
    if: |
      github.event.workflow_run.event == 'pull_request' &&
      github.event.workflow_run.conclusion == 'success'
    outputs:
      pr_number: ${{ steps.get_pr_number.outputs.pr_number }}
    steps:
      - name: Download PR info
        uses: dawidd6/action-download-artifact@575b1e4167df67acf7e692af784566618b23c71e # v2.17.0
        with:
          workflow: build-fork.yml
          run_id: ${{ github.event.workflow_run.id }}
          workflow_conclusion: success
          name: pr
          path: ./

      - name: Get PR number
        id: get_pr_number
        run: |
          echo "::set-output name=pr_number::$(cat NUM)"

      - name: Link this CI run to PR
        uses: actions/github-script@9ac08808f993958e9de277fe43a64532a609130e # v6.0.0
        with:
          script: |
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: Number(${{ steps.get_pr_number.outputs.pr_number }}),
              body: '🔎 Tests and deployment are running now!\nSee progress at ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}'
            });
  # ...
  # other jobs
  # ...
EOF

readonly OWNER="$(gh api user --jq .login)"
readonly REPO='workflow-run'

gh repo delete "$REPO" || echo "$REPO does not exist"
gh repo create --public "$REPO"

gh api --silent \
  -X PUT \
  "/repos/$OWNER/$REPO/contents/.github/workflows/build-fork.yml" \
  -f message='add build-fork.yml' \
  -f content="$(cat "$BUILD_FORK_YML" | base64)"

gh api --silent \
  -X PUT \
  "/repos/$OWNER/$REPO/contents/.github/workflows/deploy-fork.yml" \
  -f message='add deploy-fork.yml' \
  -f content="$(cat "$DEPLOY_FORK_YML" | base64)"
