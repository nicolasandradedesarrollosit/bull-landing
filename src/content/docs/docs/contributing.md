---
title: Contributing
description: How the Bull repository is built, checked and released.
---

Bull is a monorepo of npm workspaces: `@bull/runtime`, `@bull/core`, `@bull/eslint-plugin`,
`@bull/cli` and `@bull/create`, plus an example app and fixtures that the build must reject. You need
Node 20 or later; `.nvmrc` pins 22.

```bash
npm install
npm run build        # builds every package
npm test             # unit tests
npm run test:e2e     # build + tests of the binary against examples/ and fixtures/
npm run typecheck
npm run lint         # Biome: formatting, import order and lint
npm run format       # fixes what Biome can
```

## Formatting and lint

[Biome](https://biomejs.dev) formats and lints the whole repo with one config, `biome.json`: two
spaces, double quotes, 120 columns, sorted imports and the recommended rules. The fixtures are
excluded on purpose, since they break the rules to test them.

## Continuous integration

Every push and pull request runs two jobs:

- **Lint**: `biome ci`.
- **Test**: build, typecheck, unit tests, end-to-end tests and `bull check` on the example app, on
  Ubuntu and Windows with Node 20 and 22.

Dependabot opens weekly pull requests for npm dependencies and GitHub Actions.

## Releases

Releases use [Changesets](https://github.com/changesets/changesets). A pull request that changes a
published package adds a changeset:

```bash
npm run changeset
```

Pick the packages and the bump (`patch`, `minor`, `major`) and write one line for the changelog. The
`@bull/*` packages always share one version.

When changesets reach `main`, the release workflow opens a **Version packages** pull request that bumps
the versions and writes each package's `CHANGELOG.md`. Merging it publishes to npm with provenance.
The workflow needs an `NPM_TOKEN` secret with publish rights on the `@bull` scope.
