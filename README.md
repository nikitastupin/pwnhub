# pwnhub

This repository contains [writings](writings), [scripts](scripts), and other results of the GitHub Actions workflows vulnerabilities research.

If you're new to workflow vulnerabilities or looking for guidance, follow the [overview.md](writings/overview.md) to get started. Otherwise feel free to dive into a specific topic from the list below.

- [Pwn Request via non-default branch](writings/pwn-request-via-non-default-branch.md)
- [Exfiltration of organization level secrets](writings/org-level-secrets.md)
- [Related Work](https://github.com/nikitastupin/pwnhub#related-work)
- [Assesing impact of GitHub Actions workflow vulnerability](writings/assessing-impact.md)
- [The `if` condition](writings/if-condition.md)
- [The `GITHUB_TOKEN`](writings/github-token.md)
- [Tools](writings/tools.md)
- [How workflow run approvals work?](writings/how-workflow-run-approvals-work.md)

> :warning: this is an ongoing research and results will be published gradually

## Contributing

We're open to contributions! See the [contributing guide](CONTRIBUTING.md) for detailed instructions.

## Acknowledgments

Thank you for peer reviewing the original research paper (not yet published):

- Alexey Pakharev
- [Innokentii Sennovskii](https://twitter.com/rumata888)
- [Mikhail Egorov](https://twitter.com/0ang3el)

The research team:

- Artem Mikheev
- Danila Stupin
- [Ilya Tsaturov](https://twitter.com/itsaturov)
- [Mikhail Egorov](https://twitter.com/0ang3el)
- [Nikita Stupin](https://twitter.com/_nikitastupin)

Finally, we are very grateful to all other people who supported us directly or indirectly through their virtuous activities.

## Introduction

СI/CD systems allow us to offload routine tasks from humans to machines. In order to function, these systems require access to critical parts of infrastructure: code repositories, package registries, and secrets. Thus a breach in a CI/CD system may lead to a devastating supply chain compromise. Information security engineers do their best to make CI/CD systems secure. However, do we use these systems in a secure way?

This research was scoped to vulnerabilities in GitHub Actions workflows; platform vulnerabilities like [Stealing arbitrary GitHub Actions secrets](https://blog.teddykatz.com/2021/03/17/github-actions-write-access.html) were left out of scope. Finally, we analyzed only repositories belonging to bug bounty programs and vulnerability disclosure programs.

In total we analyzed more than 40000 GitHub Actions workflows over the course of more than a year and half. We identified and reported more than 90 vulnerabilities most of which were accepted as Critical and High severity. We also found new variants of Pwn Request and Code / Command Injection vulnerabilities in GitHub Actions workflows and new types of vulnerabilities.

## Related Work

[Rojan Rijal](https://twitter.com/uraniumhacker) published a blog post on Code / Command Injection vulnerabilities in GitHub Actions workflows in [Stealing secrets from GitHub Actions](https://sites.google.com/securifyinc.com/secblogs/hacking-github-actions).

Later [Jaroslav Lobačevski](https://twitter.com/yarlob) published an amazing series of blog posts on Pwn Request, Code / Command Injection in workflows and hardening techniques in [Keeping your GitHub Actions and workflows secure Part 1: Preventing pwn requests](https://securitylab.github.com/research/github-actions-preventing-pwn-requests), [Keeping your GitHub Actions and workflows secure Part 2: Untrusted input](https://securitylab.github.com/research/github-actions-untrusted-input), [Keeping your GitHub Actions and workflows secure Part 3: How to trust your building blocks](https://securitylab.github.com/research/github-actions-building-blocks) respectively along with [dozens of GitHub Security Advisories](https://securitylab.github.com/advisories/).

Series of research by [Adnan Khan](https://x.com/adnanthekhan) focusing on self-hosted runners ([One Supply Chain Attack to Rule Them All – Poisoning GitHub's Runner Images](https://adnanthekhan.com/2023/12/20/one-supply-chain-attack-to-rule-them-all/)), cache poisoning ([The Monsters in Your Build Cache – GitHub Actions Cache Poisoning](https://adnanthekhan.com/2024/05/06/the-monsters-in-your-build-cache-github-actions-cache-poisoning/) and [ActionsCacheBlasting](https://github.com/AdnaneKhan/ActionsCacheBlasting)) and TOCTOU ([ActionsTOCTOU](https://github.com/AdnaneKhan/ActionsTOCTOU)).

In [GitHub Actions check-spelling community workflow - GITHUB_TOKEN leakage via advice.txt symlink](https://github.com/justinsteven/advisories/blob/master/2021_github_actions_checkspelling_token_leak_via_advice_symlink.md) by [Justin Steven](https://github.com/justinsteven) a vulnerability in the [check-spelling/check-spelling](https://github.com/check-spelling/check-spelling) dependency action rather than a workflow itself was described. This vulnerability made `jekyll/jekyll`, `microsoft/terminal`, `PowerDNS/pdns` and other repositories vulnerable to unauthorized modification and secrets exfiltration. Also, [RyotaK](https://twitter.com/ryotkak) in [Remote code execution in Homebrew by compromising the official Cask repository](https://blog.ryotak.me/post/homebrew-security-incident-en/) described another vulnerability which was not in the workflow itself but in a dependency.

[Teddy Katz](https://twitter.com/not_an_aardvark) made several disclosures of GitHub Actions platform vulnerabilities in [Stealing arbitrary GitHub Actions secrets](https://blog.teddykatz.com/2021/03/17/github-actions-write-access.html), [How I accidentally took down GitHub Actions](https://blog.teddykatz.com/2019/11/12/github-actions-dos.html) and others which inspired several techniques.

[Omer Gil](https://twitter.com/omer_gil) in [Bypassing required reviews using GitHub Actions](https://medium.com/cider-sec/bypassing-required-reviews-using-github-actions-6e1b29135cc7) presented a technique to abuse GitHub Actions to bypass some review processes by leveraging the fact that the `github-actions[bot]` user has write access to a repository.

Grayson Hardaway showed how to identify vulnerabilties in GitHub Actions workflows using Semgrep in [Protect Your GitHub Actions with Semgrep
](https://r2c.dev/blog/2021/protect-your-github-actions-with-semgrep/). They also discussed the dangers of using the `ACTIONS_ALLOW_UNSECURE_COMMANDS` environment variable.

[How We Discovered Vulnerabilities in CI/CD Pipelines of Popular Open-Source Projects](https://cycode.com/blog/github-actions-vulnerabilities/) by Alex Ilgayev shows advanced exploitation techniques, particularly exfiltration of organization level secrets.

[Nathan Davison](https://twitter.com/nj_dav) in [Shaking secrets out of CircleCI builds - insecure configuration and the threat of malicious pull requests](https://nathandavison.com/blog/shaking-secrets-out-of-circleci-builds) discovered that CircleCI projects can be configured in a way that anyone can exfiltrate secrets with a malicious Pull Reques. And shared a non-intrusive technique to identify such vulnerabilities. They also published his findings on GitHub Actoions vulnerabilities in [Github Actions and the threat of malicious pull requests](https://nathandavison.com/blog/github-actions-and-the-threat-of-malicious-pull-requests).

[Alex Birsan](https://twitter.com/alxbrsn) published a great blog post [Dependency Confusion: How I Hacked Into Apple, Microsoft and Dozens of Other Companies](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610) on abusing name collisions of public npm, PyPI and RubyGems registries. Later [Kamil Vavra](https://twitter.com/vavkamil) and [Gal Nagli](https://twitter.com/naglinagli) expanded dependecy confusion topic to WordPress plugins in [WordPress Plugin Confusion: How an update can get you pwned](https://vavkamil.cz/2021/11/25/wordpress-plugin-confusion-update-can-get-you-pwned/) and [Wordpress Plugin Update Confusion - The full guide how to scan and mitigate the next big Supply Chain Attack](https://galnagli.com/Wordpress_Plugin_Update_Confusion/). These writings helped us to develop several gadgets.

[0xn3va/cheat-sheets/CI CD/Github](https://github.com/0xn3va/cheat-sheets/tree/main/CI%20CD/Github) gathers knowledge about GitHub Actions workflows security. Similar to this repository.

[Identifying vulnerabilities in GitHub Actions & AWS OIDC Configurations](https://medium.com/tinder/identifying-vulnerabilities-in-github-actions-aws-oidc-configurations-8067c400d5b8) is more about how AWS roles can be misconfigured but related to the GitHub Actions context.

[What the fork? Imposter commits in GitHub Actions and CI/CD](https://www.chainguard.dev/unchained/what-the-fork-imposter-commits-in-github-actions-and-ci-cd) showcases a technique where you can reference malicious content from a fork even if it has not been merged. Keep in mind that it may need some sort of social engineering.

[LOTP - Living Off The Pipeline](https://boostsecurityio.github.io/lotp/) a collection of gadgets.
