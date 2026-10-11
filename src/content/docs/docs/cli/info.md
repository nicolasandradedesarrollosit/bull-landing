---
title: bull info
description: Files per layer, each ViewModel's public API and the Views that bind it.
sidebar:
  order: 11
---

```bash
bull info [root] [--json]
```

```
  todo-app

  Layers
    View         4 file(s)
    ViewModel    1 file(s)
    Model        2 file(s)

  ViewModels (public API)
    TodoListViewModel src/viewmodel/todo-list.viewmodel.ts
      state     draft, filter
      computed  draftError, visible, remaining, hasCompleted, isEmpty
      commands  load, editDraft, add, toggle, remove, clearCompleted, setFilter
      injects   TodoRepository
      used by   src/view/todo-list.view.tsx

  Views
    src/view/todo-list.view.tsx              TodoListViewModel
    src/view/todo-item.view.tsx              presentational

  Config overrides
    MVVM203: error
```

A ViewModel that no View binds is flagged with `no View binds it yet`. `--json` prints the same
data for scripts.
