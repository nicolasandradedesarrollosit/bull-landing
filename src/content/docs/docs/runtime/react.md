---
title: React bindings and container
description: createBullApp, useViewModel, useBinding, useChildViewModel and Container.
sidebar:
  order: 2
---

```ts
import { createBullApp, useBinding, useChildViewModel, useViewModel } from "@bull-js/runtime/react";
```

`@bull-js/runtime/react` is the only part of the runtime a View may import
([MVVM205](../../rules/mvvm205/)). It is also the only place in Bull that uses React's own state hooks:
your Views use these instead. The full table of which React hooks a View may use is in
[Reactivity, from the inside](../../concepts/reactivity/#react-hooks-in-bull).

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

Destructuring works, and the rules follow destructured members:

```tsx
const { todos, add } = useViewModel(TodoListViewModel);
```

## `useBinding(readable)`

Reads a `State`, `Computed` or read-only view and re-renders when it changes.

```tsx
const todos = useBinding(vm.todos);
const saving = useBinding(vm.save.isRunning);
```

It is React's [`useSyncExternalStore`](https://react.dev/reference/react/useSyncExternalStore)
subscribed to the signal, which gives you:

- **Granular renders.** Only the components that bind a value re-render when it changes, not their
  parents or siblings. There is no need for `memo` or for splitting contexts.
- **No render for the same value.** If the new value is `Object.is`-equal to the last one, for
  example a computed that recalculates to the same result, the component does not re-render.
- **Safe concurrent rendering**, StrictMode included.

Bind at the top of the component, like any hook. Reading `vm.todos.value` instead gives you the
value once and never updates ([MVVM206](../../rules/mvvm206/)).

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
