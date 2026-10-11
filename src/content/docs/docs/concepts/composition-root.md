---
title: Composition root
description: The one file that knows every layer and wires them together.
sidebar:
  order: 3
---

`src/main.tsx` is the composition root. It is the only file allowed to import all three layers,
because its job is to connect them: create the Models, tell the container how to build each
ViewModel, and mount the root View.

```tsx
import { createBullApp } from "@bull/runtime/react";
import { TodoRepository } from "./model/todo.repository";
import { AppView } from "./view/app.view";
import { TodoListViewModel } from "./viewmodel/todo-list.viewmodel";

createBullApp({
  root: AppView,
  register: (c) => {
    c.model(TodoRepository, () => new TodoRepository());
    c.viewModel(TodoListViewModel, (c) => new TodoListViewModel(c.get(TodoRepository)));
  },
});
```

- `c.model(Token, factory)` registers a singleton: every ViewModel that asks for it gets the same
  instance.
- `c.viewModel(Token, factory)` tells `useViewModel(Token)` how to build a new instance and inject
  its dependencies.
- A ViewModel without constructor parameters does not need to be registered.

Nothing may import the composition root ([MVVM106](../../rules/mvvm106/)), and it must exist
([MVVM005](../../rules/mvvm005/)). Change its location with `compositionRoot` in
[bull.config.ts](../../configuration/).

`bull g feature <name>` adds the imports and the two `register` lines for you.
