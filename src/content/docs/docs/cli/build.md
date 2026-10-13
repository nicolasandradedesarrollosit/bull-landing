---
title: bull build
description: Checks the architecture and, only if it holds, builds for production.
sidebar:
  order: 2
---

```bash
bull build [root] [--out-dir <dir>] [--mode <mode>] [--config <file>]
```

1. Loads `bull.config.ts`.
2. Analyzes the project and prints the report.
3. **If there is any error, stops** with `Build cancelled: N MVVM architecture violations` and exit
   code 1. Nothing is written to `dist/`.
4. Otherwise runs `vite build` with React and your `vite` options.

```
  ♉ bull v0.3.0  · build

  ✓ MVVM architecture ok · 8 files (model 2 · viewmodel 1 · view 4) · 40ms

vite v8 building client environment for production...
✓ built in 200ms

  ✓ Build ready → dist/
```

Warnings (for example [MVVM203](../../rules/mvvm203/)) are printed but do not stop the build. Raise
them to errors in [bull.config.ts](../../configuration/) if you want them to.

| Option | Meaning |
|---|---|
| `--out-dir <dir>` | Output folder. Defaults to `dist`. |
| `--mode <mode>` | Vite mode, for `.env.<mode>` files. Defaults to `production`. |
| `--config <file>` | Use this file instead of `bull.config.ts`. |

Using Vite directly? Add `bullPlugin()` from `@bull-js/cli` to your `vite.config.ts`: it runs the
same check in `buildStart` and fails the build on errors.
