---
name: fj
description: Interact with forgejo instances for common tasks like raising PRs (pull requests) and commenting on issues
---
# fj (forgejo-cli)

fj is a cli tool for performing strictly non git operations, primarily for raising or closing pull requests, as well as requesting review or responding to comments.

## Which forges is this applicable?

This skill and the fj cli is for use on forgejo forges only. Generally speaking this will be scm.w7x6t.dev and codeberg.org only. Actions against Github repositories should use the gh cli and gh skill instead.

## Raising a PR

To raise a pull request perform the following operations.

1. Ensure you're on a non default branch
2. Ensure you're remote branch is pushed and up to date
3. Use the following command to raise the PR: `fj pr create '<title>' --body '<body>'`
4. Respond to the request with a link to review the PR so that I can review it
