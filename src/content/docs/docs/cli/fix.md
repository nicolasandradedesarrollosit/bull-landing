---
title: bull fix
description: Applies the automatic fixes that have a single correct answer.
sidebar:
  order: 8
---

```bash
bull fix [root] [--dry-run]
```

Some violations only have one correct fix. `bull fix` applies those, re-analyzes the project and
reports what is left. Diagnostics that can be fixed are marked with `✦ Auto-fixable` in the
terminal and in the dev overlay.

| Rule | What `fix` does |
|---|---|
| [MVVM003](../../rules/mvvm003/) wrong file name | Renames the file to the layer convention and rewrites every import that points to it. |
| [MVVM302](../../rules/mvvm302/) public mutable state | `x = this.state(…)` becomes a private `#x` plus `readonly x = this.#x.readonly`, and `this.x` becomes `this.#x` in the file. Mutable fields get `readonly`. Public constructor dependencies become `private readonly`. |
| [MVVM100](../../rules/mvvm100/) type-only import from the Model | Adds `export type { T } from "…"` to the matching ViewModel and points the View's import at it. |

Value imports from the Model, state in Views and similar problems need a design decision, so they
are left for you.

## Preview

`--dry-run` writes nothing and prints a diff per file:

```
  ○ MVVM302  src/viewmodel/counter.viewmodel.ts  made `count` private and exposed `count` as a read-only view

    src/viewmodel/counter.viewmodel.ts
      @@ line 6 @@
      -   count = this.state(0);
      +   readonly #count = this.state(0);
      +   readonly count = this.#count.readonly;
```
