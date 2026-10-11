---
title: React bindings and container
description: createBullApp, useViewModel, useBinding, useChildViewModel and Container.
sidebar:
  order: 2
---

```ts
import { createBullApp, useBinding, useChildViewModel, useViewModel } from "@bull/runtime/react";
```

`@bull/runtime/react` is the only part of the runtime a View may import
([MVVM205](../../rules/mvvm205/)).

## `createBullApp(options)`

Mounts the application. Call it once, from the [composition root](../../concepts/composition-root/).

| Option | Default | Meaning |
|---|---|---|
| `root` | — | The root View component. |
| `register(container)` | — | Registers Models and ViewModels. |
| `element` | `"#root"` | Element or selector to mount into. |
| `strict` | `true` | Wrap the app in `<StrictMode>`. |

Returns `{ container, unmount() }`.

## `useViewModel(Token)`

Gets a ViewModel for the current component. The instance is created once, built with the factory
registered in the container (or with `new Token()` if it takes no parameters), activated on mount
and deactivated on unmount.

```tsx
const vm = useViewModel(TodoListViewModel);
```

Never create a ViewModel with `new` inside a View ([MVVM204](../../rules/mvvm204/)).

## `useBinding(readable)`

Reads a `State`, `Computed` or read-only view and re-renders when it changes.

```tsx
const todos = useBinding(vm.todos);
const saving = useBinding(vm.save.isRunning);
```

## `useChildViewModel(vm)`

Activates a ViewModel that a parent passed through props, for example an item ViewModel created by
a list ViewModel.

```tsx
function TodoItemView(props: { item: TodoItemViewModel }) {
  const vm = useChildViewModel(props.item);
  const done = useBinding(vm.done);
  …
}
```

## `Container`

| Method | Meaning |
|---|---|
| `model(Token, (c) => instance)` | Registers a singleton Model. |
| `viewModel(Token, (c) => instance)` | Registers how to build a ViewModel. |
| `get(Token)` | Returns a Model, creating it on first use. |
| `createViewModel(Token)` | Builds a new ViewModel (used by `useViewModel`). |

Missing registrations throw an error that shows the exact line to add to `main.tsx`.
