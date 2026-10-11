---
title: bull explain
description: Explains a rule in the terminal, or lists every rule.
sidebar:
  order: 6
---

```bash
bull explain                 # list every rule
bull explain MVVM201         # by code
bull explain 201             # by number
bull explain view-owns-state # by ESLint slug
```

Prints the rule's summary, why it matters for MVVM, the steps to fix it and a "Don't / Do" example
when there is one. The list marks with 🔒 the rules that cannot be disabled.

```
MVVM201 · VIEW OWNS STATE (view-owns-state)
View · error · configurable · also in ESLint

State and effects live in the ViewModel, not in View hooks.

Why
  In MVVM the View has no state: it only reflects the ViewModel's and delegates actions to it. …

How to fix
  1. Move that state to the ViewModel with this.state(...) and expose it with .readonly.
  …

✗ Don't
  │ const [count, setCount] = useState(0);

✓ Do
  │ readonly #count = this.state(0);
  │ readonly count = this.#count.readonly;
```

| Option | Meaning |
|---|---|
| `--format md` | Print Markdown instead of terminal text. |
| `--all --format md --out <dir>` | Write one Markdown page per rule plus an index. This site's [rule reference](../../rules/) is generated this way. |
