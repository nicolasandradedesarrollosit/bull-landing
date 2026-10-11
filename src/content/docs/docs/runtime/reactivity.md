---
title: Reactivity
description: state, computed, effect, batch and untracked from @bull/runtime.
sidebar:
  order: 3
---

`@bull/runtime` ships a small signals implementation. Inside a ViewModel you use it through
`this.state()`, `this.computed()` and `this.effect()`; the standalone functions below are the same
primitives.

```ts
import { batch, computed, effect, state, untracked } from "@bull/runtime";
```

## `state(initial)`

A mutable source of truth.

```ts
const count = state(0);
count.value;            // read and track
count.peek();           // read without tracking
count.set(1);           // write (ignored if Object.is-equal)
count.update((n) => n + 1);
count.readonly;         // a frozen read-only view: value, peek, subscribe
count.subscribe(() => console.log("changed")); // returns an unsubscribe function
```

ViewModels keep the `State` private and expose `.readonly`:

```ts
readonly #count = this.state(0);
readonly count = this.#count.readonly;
```

## `computed(fn)`

A derived value. It is lazy (computed on first read), cached, and recomputed only after one of the
values it read changes.

```ts
const double = computed(() => count.value * 2);
```

## `effect(fn)`

Runs `fn` now and again whenever something it read changes. `fn` may return a cleanup function.
Returns a function that stops the effect.

```ts
const stop = effect(() => {
  document.title = `${count.value} items`;
  return () => {/* cleanup */};
});
```

In a ViewModel, use `this.effect(fn)`: it only runs while a View using the ViewModel is mounted,
and stops on unmount.

## `batch(fn)`

Groups several writes so reactions run once, at the end.

```ts
batch(() => {
  first.set("Ada");
  last.set("Lovelace");
});
```

## `untracked(fn)`

Runs `fn` without registering dependencies.

## Guarantees

- **Glitch-free**: reactions never observe an intermediate state, even with diamond dependencies.
- **Push-pull**: writes mark dependents dirty; values are recomputed only when read.
- `useBinding` uses `useSyncExternalStore`, so it works with concurrent rendering.
