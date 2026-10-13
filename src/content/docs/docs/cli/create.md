---
title: bull create
description: Creates a new project with the MVVM structure.
sidebar:
  order: 4
---

```bash
npm create @bull-js@latest [name]
# or, with the CLI installed
bull create [name] [--pm npm|pnpm|yarn|bun] [--no-install] [--no-git] [--template default]
```

Creates `<name>/` with a counter app that already passes every rule: the three layer folders, a
composition root, `bull.config.ts`, an ESLint flat config with `@bull-js/eslint-plugin`, a strict
`tsconfig.json` and a Vitest test for the ViewModel.

`npm create @bull-js` runs the `@bull-js/create` package, which is the same command. It works with every
package manager: `pnpm create @bull-js`, `yarn create @bull-js`, `bun create @bull-js`.

## What it does

1. **Asks**, when you give no name in an interactive terminal: the name, whether to install and
   whether to initialize git. With a name it uses the flags and asks nothing, which also suits CI.
2. **Copies the template.** The folder must not exist or must be empty. The package name comes from
   the folder name, and the `@bull-js/*` dependencies point at the version that created the project.
3. **Installs** with the package manager that ran it (read from `npm_config_user_agent`), or the one
   you pass with `--pm`. Skip it with `--no-install`.
4. **Initializes git** and makes a first commit, unless the folder is already inside a repository or
   you pass `--no-git`.

```
  ✓ Project created in my-app

    src/main.tsx
    src/model/counter.repository.ts
    src/view/bull-logo.view.tsx
    src/view/counter.view.tsx
    src/viewmodel/counter.viewmodel.test.ts
    src/viewmodel/counter.viewmodel.ts

  ✓ Initialized a git repository

  Next steps:
    cd my-app
    pnpm dev
```

For an app that already exists, use [`bull init`](../init/).
