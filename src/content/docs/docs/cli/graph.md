---
title: bull graph
description: The import graph between layers, with the edges that break MVVM.
sidebar:
  order: 7
---

```bash
bull graph [root] [--format tree|mermaid|dot|html|json] [--out <file>] [--open]
```

Builds the graph of imports between project files and marks every edge that breaks the direction
`View ──▶ ViewModel ──▶ Model` (MVVM100, 101, 102, 106) or belongs to an import cycle (MVVM105).
Exits with 1 when there is any.

## `tree` (default)

```
  View
    src/view/user-list.view.tsx
      ✗ → src/model/user.repository.ts  MVVM100
  ViewModel
    src/viewmodel/user-list.viewmodel.ts
      → src/model/user.repository.ts

  Layer edges
    View → Model                           1  ✗ MVVM100
    ViewModel → Model                      1

  ✗ 1 edge(s) break the dependency direction, 0 cycle(s)
```

## `html`

```bash
bull graph --format html --open
```

Writes `bull-graph.html` (or `--out <file>`): a self-contained page with a layered SVG layout,
columns from the composition root to the Model. Violating edges are red and edges that skip a
layer arc above it. Hover a file to trace its imports. Type-only imports are dashed.

## `mermaid` and `dot`

```bash
bull graph --format mermaid > docs/architecture.mmd
bull graph --format dot | dot -Tsvg > architecture.svg
```

Subgraphs group files by layer and violating edges are labeled with their rule code.

## `json`

The raw graph: `nodes` (file, rel, kind), `edges` (from, to, typeOnly, violation, inCycle) and
`cycles`.
