---
title: ESLint plugin
description: The file-level rules in your editor, with the same codes as the build.
---

```bash
npm install -D @bull/eslint-plugin eslint
```

```js
// eslint.config.js
import bull from "@bull/eslint-plugin";

export default [...bull.configs.recommended];
```

The recommended config applies to `src/**/*.{ts,tsx,js,jsx}`, sets up `@typescript-eslint/parser`
with JSX and enables one ESLint rule per file-level Bull rule, with the same severity:

```
src/view/user-list.view.tsx
  2:1  error  The View imports 'UserRepository' directly from the Model. → Move the use of
              'UserRepository' to UserListViewModel (inject it through the constructor).
              (MVVM100 · bull explain MVVM100)                        bull/view-imports-model
```

The rule names are the slugs of the [rule reference](../rules/), for example
`bull/view-imports-model` or `bull/viewmodel-exposes-mutable-state`.

## Same engine as the build

The plugin does not reimplement anything: it hands ESLint's AST to `@bull/core`, which extracts the
same facts and runs the same rules as `bull build`. All rules share one analysis per file, so
enabling all of them costs the same as enabling one.

Project-wide rules (missing layers, import cycles, empty layers) need the whole project and only
run in `bull build`, `bull dev` and `bull check`.

## Settings

```js
export default [
  ...bull.configs.recommended,
  {
    settings: {
      bull: { srcDir: "src", compositionRoot: "src/main.tsx", alias: { "@/": "src/" } },
    },
  },
];
```

They accept the same architecture options as [bull.config.ts](../configuration/).
