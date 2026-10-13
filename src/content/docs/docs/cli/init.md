---
title: bull init
description: Adds Bull to an existing project without overwriting anything.
sidebar:
  order: 4.5
---

```bash
bull init [root] [--dry-run]
```

For an app that already exists, usually a Vite and React one. `bull init` adds what Bull needs and
leaves everything else alone:

| What | When |
|---|---|
| `bull.config.ts` | If there is no `bull.config.*`. |
| `src/model/`, `src/viewmodel/`, `src/view/` | Each folder that does not exist yet. |
| `dev`, `build`, `preview` and `check` scripts | Each script that is not defined. An existing one, such as `"dev": "vite"`, is kept and reported. |
| `@bull-js/runtime`, `@bull-js/cli` and `@bull-js/eslint-plugin` | Each one that is not a dependency yet, at the version of the CLI that runs it. |

It needs a `package.json`. To start from nothing, use [`bull create`](../create/).

```
  ♉︎ bull v0.3.0  · init (dry run)

  + bull.config.ts  would create: empty config, ready to extend
  + src/model/  would create: model layer
  + src/viewmodel/  would create: viewmodel layer
  + src/view/  would create: view layer
  ~ package.json  would update: adds scripts.build, scripts.preview, scripts.check, @bull-js/runtime, @bull-js/cli, @bull-js/eslint-plugin
  · package.json (keeps scripts.dev ("vite"), left untouched)
```

Empty layer folders do not pass the check yet (MVVM004). After installing, fill them with a first
feature and see what else needs attention:

```bash
npm install
npx bull g feature home
npx bull doctor
```
