---
title: Overview
description: Every bull command at a glance.
sidebar:
  order: 0
---

```bash
npx bull --help
```

| Group | Command | What it does |
|---|---|---|
| Develop | [`bull` / `bull dev`](../dev/) | Dev server with live architecture checks and the browser overlay. |
| | [`bull build`](../build/) | Checks the architecture; if it holds, builds for production. |
| | [`bull preview`](../preview/) | Serves the production build. |
| | [`bull create`](../create/) | Creates a new project; also `npm create @bull`. |
| | [`bull init`](../init/) | Adds Bull to an existing project. |
| Architecture | [`bull check`](../check/) | Only the architecture check, pretty or JSON. |
| | [`bull explain`](../explain/) | Explains a rule, or lists them all. |
| | [`bull graph`](../graph/) | Import graph between layers, as a tree, Mermaid, DOT, JSON or HTML. |
| | [`bull fix`](../fix/) | Applies the safe automatic fixes. |
| Tooling | [`bull generate`](../generate/) | Scaffolds features, models, ViewModels and Views. |
| | [`bull doctor`](../doctor/) | Checks the environment and the setup. |
| | [`bull info`](../info/) | Summarizes layers and ViewModel APIs. |
| | [`bull completion`](../completion/) | Shell completions for bash, zsh, fish and PowerShell. |

Every command that takes `[root]` defaults to the current folder.

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Success. Warnings alone do not fail. |
| `1` | Architecture errors (`build`, `check`, `fix`, `generate`), a broken edge or cycle (`graph`), a failed check (`doctor`), or a usage error. |
