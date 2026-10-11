---
title: bull.config.ts
description: Every option of the Bull configuration file.
---

```ts
// bull.config.ts
import { defineConfig } from "@bull/cli";

export default defineConfig({
  srcDir: "src",
  compositionRoot: "src/main.tsx",
  allowDirs: ["assets", "styles"],
  alias: { "@/": "src/" },
  rules: { MVVM203: "error", MVVM206: "off" },
  view: { allowHooks: ["useState"] },
  dev: { port: 5173, open: false, overlay: "dismissible" },
  vite: { server: { proxy: { "/api": "http://localhost:3000" } } },
});
```

| Option | Default | Meaning |
|---|---|---|
| `srcDir` | `"src"` | Source folder, relative to the project root. |
| `compositionRoot` | `"src/main.tsx"` | The only file that may import every layer. It cannot live inside a layer. |
| `allowDirs` | `["assets", "styles"]` | Folders inside `srcDir` that may hold non-layer files. |
| `alias` | `{}` | Import aliases, so `@/model/x` is recognized as the Model layer. Mirror them in `vite.resolve.alias` and `tsconfig.json`. |
| `rules` | `{}` | Severity of configurable rules: `"off"`, `"warn"` or `"error"`. |
| `view.allowHooks` | `[]` | React hooks the View may use besides the allowed ones, for purely visual state. |
| `dev.port`, `dev.open` | Vite's | Dev server options. |
| `dev.overlay` | `"dismissible"` | `"blocking"` keeps the overlay open until the code respects MVVM; `false` disables it. |
| `vite` | `{}` | Extra Vite config, merged last. |

## What you cannot configure

Structure and dependency-direction rules are the core of MVVM. Trying to change them is an error:

```
── INVALID CONFIGURATION ─────────────────────────────────────────────── MVVM900

  MVVM100 (view imports model) is part of the MVVM core and cannot be configured.
```

The [rule reference](../rules/) says for every rule whether it can be configured.
