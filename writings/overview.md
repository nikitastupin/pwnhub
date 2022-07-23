Before diving into details, let's overview the landscape of GitHub Actions workflow vulnerabilies.

Why would the attacker hack workflows? There are at least two goals: (1) steal secrets and (2) modify the base repository in order to compromise the supply chain or users of the repository (e.g. place a backdoor or other malware). Technically, modifying the base repository is a special case of stealing secrets because the repository is usually modified with the `GITHUB_TOKEN`. Many workflows hold powerful secrets such as registry keys (npm, PyPI, DockerHub, ...), cloud credentials (AWS, Google Cloud, ...), and others. Thus workflows are critical-impact targets.

If you're new to workflow vulnerabilities, good starting point would be the "Keeping your GitHub Actions and workflows secure" series by [Jaroslav Lobačevski](https://twitter.com/yarlob):

- [Keeping your GitHub Actions and workflows secure Part 1: Preventing pwn requests](https://securitylab.github.com/research/github-actions-preventing-pwn-requests)
- [Keeping your GitHub Actions and workflows secure Part 2: Untrusted input](https://securitylab.github.com/research/github-actions-untrusted-input)
- [Keeping your GitHub Actions and workflows secure Part 3: How to trust your building blocks](https://securitylab.github.com/research/github-actions-building-blocks)
- And [dozens of GitHub Security Advisories](https://securitylab.github.com/advisories/) (search on the page with the "workflow" keyword)
