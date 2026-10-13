---
title: bull completion
description: Tab completion for every command and flag.
sidebar:
  order: 12
---

```bash
bull completion <bash|zsh|fish|powershell>
```

Prints a completion script for your shell. It completes command names, aliases (`g`) and each
command's flags, and it is generated from the CLI itself, so it never goes stale. Load it once from
your shell's startup file:

| Shell | Add this |
|---|---|
| bash | `eval "$(bull completion bash)"` in `~/.bashrc` |
| zsh | `eval "$(bull completion zsh)"` in `~/.zshrc` |
| fish | `bull completion fish > ~/.config/fish/completions/bull.fish` |
| PowerShell | `bull completion powershell \| Out-String \| Invoke-Expression` in `$PROFILE` |

`bull` must be on your `PATH`: install `@bull-js/cli` globally, or use `npx bull completion …` and
point the script at `npx bull`.
