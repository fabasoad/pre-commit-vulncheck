# Vulncheck pre-commit hooks

[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/badges/StandWithUkraine.svg)](https://stand-with-ukraine.pp.ua)
![GitHub release](https://img.shields.io/github/v/release/fabasoad/pre-commit-vulncheck?include_prereleases)
![security](https://github.com/fabasoad/pre-commit-vulncheck/actions/workflows/security.yml/badge.svg)
![linting](https://github.com/fabasoad/pre-commit-vulncheck/actions/workflows/linting.yml/badge.svg)
![functional-tests](https://github.com/fabasoad/pre-commit-vulncheck/actions/workflows/functional-tests.yml/badge.svg)

## Table of Contents

- [How it works?](#how-it-works)
- [Prerequisites](#prerequisites)
- [Hooks](#hooks)
  - [vulncheck-scan](#vulncheck-scan)
- [Customization](#customization)
  - [Description](#description)
  - [Parameters](#parameters)
    - [Vulncheck](#vulncheck)
    - [pre-commit-vulncheck](#pre-commit-vulncheck)
      - [Log level](#log-level)
      - [Log color](#log-color)
      - [Vulncheck version](#vulncheck-version)
      - [Clean cache](#clean-cache)
  - [Examples](#examples)

## How it works?

At first hook tries to use globally installed [vulncheck](https://github.com/vulncheck-oss/cli)
CLI. And if it doesn't exist then hook installs `vulncheck` into a
`.fabasoad/pre-commit-vulncheck` temporary directory that will be removed after
scanning is completed.

## Prerequisites

The following tools have to be available on a runner prior using this pre-commit
hook:

- [bash >=4.0](https://www.gnu.org/software/bash/)
- [curl](https://curl.se/)

## Hooks

<!-- markdownlint-disable-next-line MD013 -->

> `<rev>` in the examples below, is the latest revision tag from [fabasoad/pre-commit-vulncheck](https://github.com/fabasoad/pre-commit-vulncheck/releases)
> repository.

### vulncheck-scan

This hook runs [vulncheck scan .](https://github.com/vulncheck-oss/cli?tab=readme-ov-file#scan-a-repository-for-vulnerabilities)
command.

```yaml
repos:
  - repo: https://github.com/fabasoad/pre-commit-vulncheck
    rev: <rev>
    hooks:
      - id: vulncheck-scan
```

## Customization

### Description

There are 2 ways to customize scanning for both `vulncheck` and `pre-commit-vulncheck`:
environment variables and arguments passed to [args](https://pre-commit.com/#config-args).

You can pass arguments to the hook as well as to the `vulncheck` itself. To distinguish
parameters you need to use `--vulncheck-args` for `vulncheck` arguments and `--hook-args`
for `pre-commit-vulncheck` arguments. Supported delimiter is `=`. So, use `--hook-args=<arg>`
but not `--hook-args <arg>`. Please find [Examples](#examples) for more details.

### Parameters

#### Vulncheck

You can install `vulncheck` locally and run `vulncheck scan --help` to see all
the available arguments:

<!-- markdownlint-disable MD013 -->

```shell
$ vulncheck version
vulncheck version 0.8.5 (2024-12-12)
https://github.com/vulncheck-oss/cli/releases/tag/v0.8.5

$ vulncheck --help
Work seamlessly with the VulnCheck API.

Usage:
  vulncheck [command]

Examples:
$ vulncheck indices list
$ vulncheck index abb
$ vulncheck backup abb


Core Commands
  auth        Authenticate vulncheck with the VulnCheck portal

Additional Commands:
  backup      Download a backup of a specified index
  completion  Generate the autocompletion script for the specified shell
  cpe         Look up a specified cpe for any related CVEs
  help        Help about any command
  index       Browse or list an index
  indices     View indices
  offline     Offline commands
  pdns        List IP Intelligence Protective DNS records
  purl        Look up a specified PURL for any CVEs or vulnerabilities
  rule        Look up a specified rule for Initial Access Intelligence
  scan        Scan a directory for vulnerabilities
  tag         List IP Intelligence Tags
  token       Manage Tokens
  version     Show the current version, build date, and changelog URL

Flags:
      --help   Show help for command

Use "vulncheck [command] --help" for more information about a command.
```

<!-- markdownlint-enable MD013 -->

#### pre-commit-vulncheck

Here is the precedence order of `pre-commit-vulncheck` tool:

- Parameter passed to the hook as argument via `--hook-args`.
- Environment variable.
- Default value.

For example, if you set `PRE_COMMIT_VULNCHECK_LOG_LEVEL=warning` and `--hook-args=--log-level
error` then `error` value will be used.

##### Log level

With this parameter you can control the log level of `pre-commit-vulncheck` hook
output. It doesn't impact `vulncheck` log level output. To control `vulncheck`
log level output please look at the [Vulncheck parameters](#vulncheck).

- Parameter name: `--log-level`
- Environment variable: `PRE_COMMIT_VULNCHECK_LOG_LEVEL`
- Possible values: `debug`, `info`, `warning`, `error`
- Default: `info`

##### Log color

With this parameter you can enable/disable the coloring of `pre-commit-vulncheck`
hook logs. It doesn't impact `vulncheck` logs coloring.

- Parameter name: `--log-color`
- Environment variable: `PRE_COMMIT_VULNCHECK_LOG_COLOR`
- Possible values: `true`, `false`
- Default: `true`

##### Vulncheck version

Specifies specific `vulncheck` version to use. This will work only if `vulncheck`
is not globally installed, otherwise globally installed `vulncheck` takes precedence.

- Parameter name: `--vulncheck-version`
- Environment variable: `PRE_COMMIT_VULNCHECK_VULNCHECK_VERSION`
- Possible values: Vulncheck version that you can find [here](https://github.com/vulncheck-oss/cli/releases)
- Default: `latest`

##### Clean cache

With this parameter you can choose either to keep cache directory (`.fabasoad/pre-commit-vulncheck`),
or to remove it. By default, it removes cache directory. With `false` parameter
cache directory will not be removed which means that if `vulncheck` is not installed
globally every subsequent run won't download `vulncheck` again. Don't forget to
add cache directory into the `.gitignore` file.

- Parameter name: `--clean-cache`
- Environment variable: `PRE_COMMIT_VULNCHECK_CLEAN_CACHE`
- Possible values: `true`, `false`
- Default: `true`

### Examples

Pass arguments separately from each other:

```yaml
repos:
  - repo: https://github.com/fabasoad/pre-commit-vulncheck
    rev: <rev>
    hooks:
      - id: vulncheck-scan
        args:
          - --hook-args=--log-level debug
          - --vulncheck-args=--file
          - --vulncheck-args=--file-name result.json
```

Pass arguments altogether grouped by category:

```yaml
repos:
  - repo: https://github.com/fabasoad/pre-commit-vulncheck
    rev: <rev>
    hooks:
      - id: vulncheck-scan
        args:
          - --hook-args=--log-level debug
          - --vulncheck-args=--file --file-name result.json
```

Set these parameters to have the minimal possible logs output:

```yaml
repos:
  - repo: https://github.com/fabasoad/pre-commit-vulncheck
    rev: <rev>
    hooks:
      - id: vulncheck-scan
        args:
          - --hook-args=--log-level=error
```
