# How workflow run approvals work?

There seem to be a common misconception regarding how workflow run approvals work. Here we will clarify this and support our reasoning with practical (and reproducible) examples.

## Theory

The workflow run approvals are described on the [Approving workflow runs from public forks](https://docs.github.com/en/actions/managing-workflow-runs/approving-workflow-runs-from-public-forks) page. They are enabled by default for first-time contributors for new repositories and can be enabled or disabled for all outside collaborators.

The blue note on the aforementioned page hints that `pull_request_target` workflows will always run, regardless of approval settings.

However, it is not only `pull_request_target` workflows that ignore these settings. In practice, approvals apply only to `pull_request` workflows. For example, `pull_request_review` will also always run.

This makes sense because as described in [GitHub Actions update: Helping maintainers combat bad actors](https://github.blog/2021-04-22-github-actions-update-helping-maintainers-combat-bad-actors/) the main reason why GitHub added the approval process is because cryptominers abused GitHub Actions to mine cryptocurrency. Accidentally, this also became an additional layer of defence against some of the vulnerability types.

## Practice

Navigate to the root of the repository and run the `pull-request-review.sh` script. Note that you need `gh` installed and logged in.

```bash
bash scripts/test/pull-request-review.sh
```

Then you may want to set the `Require approval for all outside collaborators` in the repository settings.

Finally, with another account submit a pull request review (either comment, approve, or request changes) and see that the workflow runs even though the review was submitted by an outside collaborator.
