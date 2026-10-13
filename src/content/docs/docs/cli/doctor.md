---
title: bull doctor
description: Checks the environment and the project setup, with a hint for every problem.
sidebar:
  order: 10
---

```bash
bull doctor [root]
```

```
  ✓ Node.js 24.19.0
  ✓ React 19.3.0
  ✓ @bull-js/runtime 0.2.0
  ✓ A single copy of React
  ✓ Vite 8.3.4
  ✓ bull.config.ts loads
  ✓ index.html loads /src/main.tsx
  ✓ tsconfig.json uses react-jsx and strict mode
  ✓ src/model, src/viewmodel and src/view exist
  ✓ ESLint uses @bull-js/eslint-plugin
  ✓ Architecture respects MVVM

  Healthy
```

| Check | Fails when |
|---|---|
| Node.js | The version is older than 20. |
| React | `react` or `react-dom` is missing, or their versions differ. |
| `@bull-js/runtime` | It is not installed. |
| Single copy of React | The app and `@bull-js/runtime` resolve different copies (the cause of "Invalid hook call"). |
| `bull.config` | It does not load, or has invalid values (MVVM900). |
| `index.html` | It is missing. Warns when it does not load the composition root. |
| Layers | A layer folder or the composition root is missing. |
| Architecture | There are architecture errors. |

`tsconfig.json` and the ESLint plugin are suggestions (`!`): they never fail. Exit code 1 means at
least one check failed.
