# General Development and System Usage Guidance

## Using this system

This machine is your sandbox for software engineering, feel free to use anything under the home directory as you see fit. Never try to leave the home directory, never try to write outside of the home directory and never try to elevate your level of privileges.

### Installing tools

This system is running a custom build ublue/ucore, a immutable OS based on Fedora. This means that tools cannot be installed using apt, dnf, or any other integrated package manager. All tools must be installed to the home directory as that is mutable. The following is the required order of preference for aquiring cli tools:

1. Install using the `mise` skill
2. Using the official install script provided by the developer
3. Pulling/building binaries and placing them in ~/.local/bin so that they're on the PATH.

### Interacting with repositories

#### Cloning and opening

1. When asked to clone a repository with a short id like: my_org/my_repo then attempt to checkout in the following order of preference:
  a. ssh://git@scm.w7x6t.dev/my_org/my_repo.git
  b. ssh://git@codeberg.org/my_org/my_repo.git
  c. ssh://git@github.com/wtaylor/my_org/my_repo.git
2. When denied access, don't try any other remotes and ask me for access.
3. All repositories from scm.w7x6t.dev should be cloned using ssh as well as all repositories on any forge under an org/username of wtaylor. Otherwise, public repositories not owned by me should be cloned using https.
4. All repositories should be cloned underneath `~/code` unless otherwise specified or cloning for your own cache.
5. Upon cloning a new repository, along with your own discovery, if the repository has a `mise.toml` ask me if I wish to trust the repository.
6. When opening a project use `mise ls` and `mise tasks` to see what can be done using existing scripts and tool installs.

#### Working on a fix/feature

Here are some general tips when working on a repository

- Stay on the default branch until the scope of a change is obvious, when a unit of work is suspected, ask me if you should checkout a new branch, come up with the branch name in your ask.
- When coming up with a branch name, it should follow the format: `<feat/fix>/extremely-short-summary`, for example: `feat/select-user-on-home-screen` or `fix/blank-box-on-firefox`.
- Unless specified in chat or in the repositories readme, assume that commits should follow the conventional commits specification. In short, all commits should be in the following format:
  - feat/fix/chore: short description of feature or bug that is getting fixed
  - details of the feature's implementation or the bugs fix
- When asked to raise a pull request raise a pull request using the fj or gh skill
  - Use the fj skill when raising a PR in a repos remote resides in either:
    - scm.w7x6t.dev
    - codeberg.org
  - Use the gh skill when a repos remote is on github.
- The majority of the time, the PR will be squash merged, to this end, the title and body of the PR should form a single conventional commit with the title being `feat/fix/chore: short summary of change` and the body of the PR being a summary of all of the changes across all commits on the branch. `chore` is reserved for PRs that won't impact any running systems or released binaries, primarily it will only be used for documentation updates.

### Working with me

Below are my preferences when working with me, use this to inform your responses.

1. I like working with machines, accurate, precise and concise answers are preferred.
2. Don't include extra information unless I am trying to diagnose/debug an issue and you think it is potentially relevant.
