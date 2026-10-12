---
title: Introduction
description: What Bull is, what it enforces and why.
---

Bull is an opinionated React framework with a CLI in the spirit of Vite and Next, and one
difference: the **Model–View–ViewModel** architecture is part of the compiler. If the structure is
wrong or a layer talks to the wrong neighbor, `bull build` stops and explains what to change.

Bull is not a bundler. Vite does the bundling; Bull checks the architecture before Vite runs and
gives you the runtime that makes MVVM comfortable in React.

## The problem it solves

React lets you put anything anywhere. A component can fetch data, hold business rules, store state
and render all at once. That works until the screen needs a test, a second data source or a
redesign, and every change touches everything.

MVVM splits that work into three layers with one-way dependencies:

```
View ──▶ ViewModel ──▶ Model
```

- **Model**: entities, business rules and data access. Knows nothing about screens.
- **ViewModel**: the state and actions of one screen, written as a plain TypeScript class.
- **View**: React components that read the ViewModel and call its commands. No state of their own.

Plenty of teams agree with this on paper. Bull makes it the only way the code compiles.

## What Bull enforces

- The folders `src/model`, `src/viewmodel` and `src/view` must exist, and every file in `src/`
  belongs to one of them (or is the composition root).
- Imports only go downwards: the View never imports the Model, the ViewModel never imports the
  View or React, and the Model never imports anything above it.
- Each layer keeps to its job: no `fetch` in a View, no `document` in a ViewModel, no public mutable
  state on a ViewModel, no `useState` in a View.

There are [29 rules](../rules/) in total. Each one has a stable code (`MVVM100`), an explanation
of why it matters, concrete steps to fix it and, for some, an automatic fix.

## Where the rules run

| Where | What happens |
|---|---|
| `bull build` | The architecture is checked before Vite runs. Any error stops the build with exit code 1. |
| `bull dev` | Every change is re-checked. Violations appear in the terminal and in a browser overlay. |
| `bull check` | Only the check, with `--format json` for CI. |
| `@bull/eslint-plugin` | The same rules, underlined in your editor. |

## What it is built on

- **Vite, the bundler.** The dev server, hot reload and the production build are Vite's. Bull
  analyzes the project first and adds the dev overlay as a Vite plugin. Any Vite option goes in the
  `vite` key of [bull.config.ts](../configuration/).
- **React, the View.** Views are plain React function components. `useBinding` subscribes them to a
  ViewModel through `useSyncExternalStore`, so they re-render only when what they read changes.
- **Knockout, the idea.** Knockout.js brought MVVM to the browser with observables
  (`ko.observable`), computeds (`ko.computed`) and declarative bindings. Bull's `state`,
  `computed` and `command` are the same idea, typed and testable as plain classes, without bindings
  in the HTML: React is the binding layer.

The reactivity is the core of Bull: state lives in signals inside the ViewModel, and React only
renders what they say. [Reactivity, from the inside](../concepts/reactivity/) explains it end to end.

## What is in the box

- `@bull/runtime`: signals, the `ViewModel` base class, commands, a DI container and React bindings.
- `@bull/core`: the analyzer and the rule catalog.
- `@bull/cli`: `dev`, `build`, `preview`, `check`, `explain`, `create` and `init`, plus tooling:
  `generate`, `fix`, `graph`, `doctor`, `info` and `completion`.
- `@bull/create`: `npm create @bull`, the same `create` as its own package.
- `@bull/eslint-plugin`: the file-level rules for your editor.

Next: [create your first project](../getting-started/), then read
[how the reactivity works](../concepts/reactivity/).
