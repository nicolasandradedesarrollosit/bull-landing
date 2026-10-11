---
title: Introduction
description: What Bull is, what it enforces and why.
---

Bull is a React bundler and CLI in the spirit of Vite and Next, with one difference: the
**Model–View–ViewModel** architecture is part of the compiler. If the structure is wrong or a layer
talks to the wrong neighbor, `bull build` stops and explains what to change.

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

## What is in the box

- `@bull/runtime`: signals, the `ViewModel` base class, commands, a DI container and React bindings.
- `@bull/core`: the analyzer and the rule catalog.
- `@bull/cli`: `dev`, `build`, `preview`, `check`, `explain`, `create`, plus tooling:
  `generate`, `fix`, `graph`, `doctor` and `info`.
- `@bull/eslint-plugin`: the file-level rules for your editor.

Next: [create your first project](../getting-started/).
