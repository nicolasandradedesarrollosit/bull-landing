---
title: bull preview
description: Serves the production build locally.
sidebar:
  order: 3
---

```bash
bull preview [root] [--port <port>] [--open] [--host [host]] [--out-dir <dir>] [--config <file>]
```

Serves the output of [`bull build`](../build/) with Vite's preview server, so you can check the
production bundle before deploying it.

| Flag | What it does |
|---|---|
| `--port` | Port to listen on. |
| `--open` | Opens the browser. |
| `--host` | Exposes the server on the network (optionally on a given address). |
| `--out-dir` | Folder with the build, if it is not `dist/`. |
| `--config` | A config file other than `bull.config.ts`. |

If there is no build yet, it says so instead of serving an empty folder:

```
  ✗ There is no build in dist/ to preview.
    Run `bull build` first.
```
