---
title: bull check
description: Runs only the architecture check, for humans or for CI.
sidebar:
  order: 5
---

```bash
bull check [root] [--format pretty|json]
```

Analyzes the project and prints the same report as `bull build`, without building. Exits with 1
when there are errors.

## In CI

```yaml
- run: npx bull check
```

## JSON output

`--format json` prints a stable document (version 1) for tools:

```json
{
  "version": 1,
  "ok": false,
  "errorCount": 1,
  "warningCount": 0,
  "stats": { "model": 2, "viewmodel": 1, "view": 4, "root": 1, "allowed": 0, "outside": 0, "ignored": 1 },
  "diagnostics": [
    {
      "code": "MVVM100",
      "slug": "view-imports-model",
      "severity": "error",
      "category": "dependencies",
      "title": "VIEW IMPORTS MODEL",
      "message": "The View imports `TodoRepository` directly from the Model.",
      "file": "src/view/todo-list.view.tsx",
      "line": 2,
      "column": 1,
      "why": "The View only knows its ViewModel. …",
      "fix": ["Move the use of `TodoRepository` to TodoListViewModel …"],
      "fixable": false,
      "explain": "bull explain MVVM100"
    }
  ]
}
```
