---
title: bull generate
description: Scaffolds features, models, ViewModels and Views with the right names.
sidebar:
  order: 9
---

```bash
bull generate <type> <name> [--kind <kind>] [--dry-run] [--no-test] [--root <dir>]
bull g <type> <name>
```

Names are normalized: `TodoList`, `todo-list`, `todo list` and `TodoListViewModel` all become
`todo-list.*` files and `TodoList*` classes. Existing files are never overwritten. After writing,
the project is checked.

## `feature`

```bash
bull g feature shopping-cart
```

```
  + src/model/shopping-cart.repository.ts
  + src/viewmodel/shopping-cart.viewmodel.ts
  + src/viewmodel/shopping-cart.viewmodel.test.ts
  + src/view/shopping-cart.view.tsx
  ~ src/main.tsx  registered the Model and ViewModel
```

A full vertical slice: a repository, a ViewModel that receives it through the constructor (with
`items`, `isEmpty`, `load` and `add`), a test for it and a View bound to it. The composition root
gets the imports and the `c.model(…)` / `c.viewModel(…)` lines.

## `model`

```bash
bull g model user                     # src/model/user.model.ts
bull g model user --kind entity       # src/model/user.entity.ts
bull g model user --kind repository   # src/model/user.repository.ts
bull g model pricing --kind service   # src/model/pricing.service.ts
```

## `viewmodel`

```bash
bull g viewmodel cart     # cart.viewmodel.ts (+ cart.viewmodel.test.ts when Vitest is installed)
```

## `view`

```bash
bull g view cart          # bound to CartViewModel if it exists, presentational otherwise
```

| Option | Meaning |
|---|---|
| `--kind` | For `model`: `model`, `entity`, `repository` or `service`. |
| `--dry-run` | Print what would be written. |
| `--no-test` | Skip the ViewModel test. |
| `--root <dir>` | Project root. |

Aliases: `m` for model, `vm` for viewmodel, `v` for view, `f` for feature.
