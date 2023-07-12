# Tools 

## Gato

https://github.com/praetorian-inc/gato

> The tool has a few features as part of the attack and enumerate modules that can be used to identify and abuse a self-hosted runner.
> 
> The first attack feature is automatically pushing a new workflow to a feature branch that runs on a self-hosted runner (requires write access with repo and workflow scopes token). This workflow can contain arbitrary shell commands. This isn't any different than doing it manually via Git, but it's quite a lot faster.
> 
> The second feature is creation of a fork PR containing a new workflow that runs on a self-hosted runner (this can be done on public repositories). By default GitHub requires approval for first time contributors to run workflows on the pull_request trigger, but even a simple documentation change would make you a contributor to a repository.
> 
> Finally, as part of the enumeration module Gato will download run logs for workflows via the GitHub API and parse out the machine name of the runner. This can be used to find repositories that are using non-ephemeral runners (the runner name will often hint whether the runner is ephemeral or not).

## `bypass-another-branch.sh`

https://github.com/nikitastupin/pwnhub/blob/main/scripts/bypass-another-branch.sh