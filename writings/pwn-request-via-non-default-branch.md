# Pwn Request via a non-default branch

After reading the [Keeping your GitHub Actions and workflows secure Part 1: Preventing pwn requests](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/) blog post I digged deeper into the vulnerability and found that many maintainers fall into the same pitfall while remediating the Pwn Request vulnerability. This discovery led to 8 fix bypasses immideately and several later.

## How the bypass works?

The bypass uses the fact that the `pull_request_target` event runs workflows from a target branch (in contrast to most other events that always run workflows from the default branch). So by changing the target branch one can bypass a fix.

Consider the following scenario:

1. A workflow with the Pwn Request vulnerability is committed to the default branch of a repository.
1. Maintainers create new branches from the default branch. In this way vulnerability propogates to another branches.
1. The vulnerability gets fixed in the default branch.
1. However, the non-default branches still contain the vulnerability.

If a malicious user creates a pull request against a non-default branch in which the vulnerable workflow still exist, the vulnerable version of the workflow will be executed, not the fixed one. In this way the malicious user will bypass the fix.

## How `branches` and `branches-ignore` can (unintentionally) prevent the bypass?

Having a vulnerable workflow in a non-default branch is not always exploitable. When using the `pull_request` and `pull_request_target` events, one can configure a workflow to run only for pull requests that target specific branches using the [`branches` and `branches-ignore` filters](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onpull_requestpull_request_targetbranchesbranches-ignore).

For example, the [continuous-integration.yml](https://github.com/aws/amazon-chime-sdk-js/blob/bfc4c600fb7e68f2d358ecb6c7fd096d30b2d430/.github/workflows/continuous-integration.yml) workflow had a pwn request vulnerability ([GHSL-2020-249](https://securitylab.github.com/advisories/GHSL-2020-249-aws-amazon-chime-sdk-js-workflow/)). Maintainers applied [the fix](https://github.com/aws/amazon-chime-sdk-js/commit/96cf13e837c2e92c8c8ff1ef93e88d303e89b22b) only to the default branch. However, the workflow runs only on pull requests to the `master` and `release-1.x` branches:

```yaml
name: CI Workflow

on:
  pull_request_target:
    branches:
      - master
      - release-1.x
...
```

The vulnerability was fixed at `master` and branches matching the `release-1.x` pattern didn't contain the vulnerable workflow thus it was not possible to run the workflow by targeting another branch so it was not possible to bypass the fix.

## Remediation

The remediation is straightforward. When fixing the Pwn Request vulnerability either (1) fix it in all branches or (2) fix it in the default branch and delete all non-default branches that contain the vulnerable workflow.

## Automation

Some repositories have a lot of branches and workflows so checking every branch and workflow manually would be at least tedious. I've created [the `bypass-another-branch.sh` script](../scripts/bypass-another-branch.sh) that goes through each branch and extracts unique workflow files.