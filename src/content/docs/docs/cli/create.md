---
title: bull create
description: Creates a new project with the MVVM structure.
sidebar:
  order: 4
---

```bash
npx @bull/cli create <name> [--template default]
```

Creates `<name>/` with a counter app that already passes every rule: the three layer folders, a
composition root, `bull.config.ts`, an ESLint flat config with `@bull/eslint-plugin`, a strict
`tsconfig.json` and Vitest for ViewModel tests.

The folder must not exist or must be empty. The package name is derived from the folder name.

```
  src/main.tsx
  src/model/counter.repository.ts
  src/styles/app.css
  src/view/bull-logo.view.tsx
  src/view/counter.view.tsx
  src/viewmodel/counter.viewmodel.ts

  Next steps:
    cd my-app
    npm install
    npm run dev
```
