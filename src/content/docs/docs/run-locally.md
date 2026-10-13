---
title: Run Bull locally
description: Build the Bull monorepo from source, run its tests and the example app.
---

Until the packages are published, run Bull from its source repository. This documentation repo
ships two scripts that do every step for you.

## With the setup scripts

From the root of this docs repository:

```bash
# macOS / Linux / Git Bash
./scripts/setup.sh --repo ../bull
```

```powershell
# Windows PowerShell
./scripts/setup.ps1 -Repo ..\bull
```

`--repo` (`-Repo`) accepts a local path or a git URL. A URL is cloned into `.bull/`.

The scripts:

1. check that Node.js 20+ and npm are available,
2. install the monorepo dependencies,
3. build the four packages,
4. run the unit tests (and the end-to-end tests with `--e2e` / `-E2E`),
5. check the architecture of the example app,
6. start the example app's dev server (skip it with `--no-dev` / `-NoDev`).

Use `--dry-run` (`-DryRun`) to print the commands without running them, and `--help` (`-Help`)
for every option.

## By hand

```bash
git clone <bull-repo-url> bull
cd bull
npm install
npm run build
npm test
npm run test:e2e
node packages/cli/dist/bin.js check examples/todo-app
cd examples/todo-app && npm run dev
```

## Monorepo scripts

| Script | What it does |
|---|---|
| `npm run build` | Builds `@bull-js/runtime`, `@bull-js/core`, `@bull-js/eslint-plugin` and `@bull-js/cli`. |
| `npm test` | Unit tests of every package and of the example app's ViewModel. |
| `npm run test:e2e` | Builds, then runs the CLI binary against the example app and the broken fixtures. |
| `npm run typecheck` | TypeScript checks of the four packages. |
| `npm run docs` | Regenerates `docs/rules` from the rule catalog. |

## Repository layout

```
packages/
  runtime/        signals, ViewModel, Command, Container, React bindings
  core/           analyzer, rules, formatters, import graph
  cli/            commands, Vite plugin, browser overlay, create template
  eslint-plugin/  ESLint rules built on @bull-js/core
examples/todo-app reference application
fixtures/         apps broken on purpose, used by the end-to-end tests
assets/brand/     the bull logo
```

## Refresh the rule pages of this site

The [rule reference](../rules/) is generated from the rule catalog:

```bash
BULL_REPO=../bull npm run sync:rules
```
