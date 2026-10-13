---
title: Getting started
description: Create a Bull project, run it and build it.
---

Bull needs **Node.js 20 or newer**.

## Create a project

```bash
npm create @bull-js@latest my-app
cd my-app
npm run dev
```

It works with any package manager (`pnpm create @bull-js`, `yarn create @bull-js`, `bun create @bull-js`)
and installs with the one you used. Without a name it asks for the details. See
[`bull create`](../cli/create/) for the flags, or [`bull init`](../cli/init/) to add Bull to an app
that already exists.

`create` writes a counter app that already follows the architecture:

```
my-app/
├── index.html
├── bull.config.ts
├── eslint.config.js
└── src/
    ├── main.tsx                         composition root
    ├── model/counter.repository.ts      data access
    ├── viewmodel/counter.viewmodel.ts   state and commands
    └── view/counter.view.tsx            what gets rendered
```

## The scripts

| Script | Command | What it does |
|---|---|---|
| `npm run dev` | `bull` | Dev server with live architecture checks and the browser overlay. |
| `npm run build` | `bull build` | Checks the architecture, then builds to `dist/`. |
| `npm run preview` | `bull preview` | Serves the production build. |
| `npm run check` | `bull check` | Only the architecture check. |
| `npm test` | `vitest run` | Runs the ViewModel tests. |
| `npm run lint` | `eslint src` | The file-level rules through ESLint. |

## Add your first feature

```bash
npx bull g feature todo-list
```

This creates a repository, a ViewModel that receives it through its constructor, a test for the
ViewModel and a View bound to it, and registers both in `src/main.tsx`. Render `<TodoListView />`
from your root View to see it.

## Break something on purpose

Open `src/view/counter.view.tsx` and import the repository directly:

```tsx
import { CounterRepository } from "../model/counter.repository";
```

The dev overlay shows `VIEW IMPORTS MODEL (MVVM100)` with the line, the reason and the fix, and
`npm run build` refuses to produce a bundle until you undo it.

:::tip
Run `npx bull explain MVVM100` to read the full explanation of any rule, with examples.
:::

## Check your setup

```bash
npx bull doctor
```

`doctor` checks Node, React, a single copy of React, the config, `index.html`, `tsconfig.json`, the
ESLint plugin and the architecture, and gives a hint for anything that is off.
