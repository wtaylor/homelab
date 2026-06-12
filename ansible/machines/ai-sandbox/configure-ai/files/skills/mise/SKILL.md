---
name: mise
description: Install and version command line tools, run mise tasks, and configure your project or environment
---
# mise-en-place (mise)

mise is a cli tool that is used to version and install various tools for a project, the main configuration file is mise.toml at the root of a project. Tasks are defined in either the mise.toml or in a seperate mise-tasks/ directory also at the root of the project.

## First time repo setup

When cloning a repo, mise trust should be run if there is a mise.toml in the project, ask for permission to do so. After trusting the repository `mise install` will install all of the tooling in the mise.toml

## Installing tools

All kinds of tooling is available through mise, it rivals brew in most use cases. The projects mise.toml will list all the tools available to a project. Additionally `mise ls` will list all of the tools available to the environment including tools installed globally.

To search for a tool use:

```bash
mise search <tool_name>
```

To install a tool use:

```bash
mise use --pin <tool_name>
```

Note: pinning should always be used so that the version of a tool is pinned in `mise.toml`

### Global mise tools

~/.config/mise/config.toml is the global mise config, in there are tools available to you regardless of project. Tools should be installed globally only when they're irrelevant to the project, or when they're wanted in a global context.

To install a tool globally:

```bash
mise use -g --pin <tool_name>
```

## Mise tasks

`mise` is also a taskrunner that enables you to define reuseable scripts tasks as scripts defined in the mise.toml or under the .mise-tasks/ directory.

mise tasks can be run using the following command:

```bash
mise run my_task_name <args>
```

For running tasks defined in .mise-tasks, directories are signified using `:` as a seperator, and _default as a name for the top level of that directory. For example, to run the task at `./mise-tasks/docker/build.sh`, you should use `mise run docker:build` and to run a task at `./mise-tasks/docker/_default.sh` use `mise run docker`.
