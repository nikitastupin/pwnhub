# [DRAFT] The `if` condition

The following patterns are interpreted as a string thus always equals to true.

```yaml
if: |
  ${{ ... }}
```

```yaml
if: >
  ${{ ... }}
```

This example runs on both Issue and Pull Request comments.

```yaml
on:
  issue_comment:

jobs:
  test:
    if: |
      ${{ github.event.issue.pull_request }}
    runs-on: ubuntu-latest
    steps:
      - run: echo Hello, world!
```

The next one, however, runs only on Pull Request comments (notice the absence of `${{ ... }}`).

```yaml
on:
  issue_comment:

jobs:
  test:
    if: |
      github.event.issue.pull_request
    runs-on: ubuntu-latest
    steps:
      - run: echo Hello, world!
```

So it is safe to use `if`:

- without `${{ ... }}`
- without `|` and `>`
- with `>-`

## Further research

What are the other ways an expression in the `if` condition can be misinterpreted?
