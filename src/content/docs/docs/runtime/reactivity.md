---
title: Reactivity API
description: Every member of state, computed, effect, batch and untracked from @bull-js/runtime.
sidebar:
  order: 3
---

The reference for Bull's signals. For how they work and why, read
[Reactivity, from the inside](../../concepts/reactivity/) first.

Inside a ViewModel you use them through `this.state()`, `this.computed()` and `this.effect()`. The
standalone functions are the same primitives, useful in tests and in plain TypeScript:

```ts
import { batch, computed, effect, state, untracked } from "@bull-js/runtime";
import type { Readable, ReadonlyState } from "@bull-js/runtime";
```

## `Readable<T>`

What every observable value has in common, and the only thing a View ever sees.

| Member | Type | Behavior |
|---|---|---|
| `value` | `T` | Reads the value. Inside a computed or an effect, it also **subscribes** to it. |
| `peek()` | `() => T` | Reads the value **without** subscribing. |
| `subscribe(listener)` | `(listener: () => void) => () => void` | Calls `listener` after every change, and returns the function that unsubscribes. `useBinding` is built on it. |

`ReadonlyState<T>` is a `Readable<T>`: the type of what a ViewModel exposes with `.readonly`.

## `state(initial)` → `State<T>`

A value you can write. The source of truth.

```ts
const count = state(0);

count.value;                 // 0, and subscribes inside a computed or effect
count.peek();                // 0, without subscribing
count.set(1);                // writes and notifies
count.set(1);                // same value (Object.is): nothing happens
count.update((n) => n + 1);  // writes from the current value: 2
count.readonly;              // a frozen Readable with no set or update
count.subscribe(() => {});   // returns an unsubscribe function
```

| Member | Behavior |
|---|---|
| `value`, `peek()`, `subscribe()` | As in `Readable<T>`. |
| `set(next)` | Writes `next`. If it is `Object.is`-equal to the current value, nothing happens. Otherwise dependents are marked dirty, and reactions run once the write ends, or when the enclosing `batch` ends. |
| `update(fn)` | `set(fn(current))`. Return a **new** array or object: mutating the current one in place is not a change. |
| `readonly` | A frozen `{ value, peek, subscribe }` that reflects every change. The same object every time you read it. |

In a ViewModel, keep the `State` private and expose its read-only view
([MVVM302](../../rules/mvvm302/)):

```ts
readonly #count = this.state(0);
readonly count = this.#count.readonly;
```

## `computed(fn)` → `Computed<T>`

A value derived from others.

```ts
const total = computed(() => price.value * quantity.value);
total.value; // calculated now, then cached
```

| Member | Behavior |
|---|---|
| `value` | Returns the cached value, recalculating first if a dependency changed since the last read. Subscribes like any `Readable`. |
| `peek()` | The same, without subscribing. |
| `subscribe(listener)` | Calls `listener` when the result may have changed. While it has subscribers, the computed recalculates eagerly so it can notify. |

- **Lazy**: `fn` doesn't run until someone reads the computed. A computed nobody reads costs nothing.
- **Cached**: reading it twice without changes runs `fn` once.
- **Dynamic dependencies**: they are recorded on every run, so they follow the branches `fn` takes.
- **Errors**: if `fn` throws, the read throws. The computed stays dirty and tries again on the next
  read.
- `fn` must not write state. Derive, don't mutate.

## `effect(fn)` → `stop()`

Code that runs again whenever what it read changes.

```ts
const stop = effect(() => {
  const id = setInterval(tick, delay.value);
  return () => clearInterval(id); // cleanup
});
```

- Runs `fn` **immediately**, and again **synchronously** after each change to something it read. No
  microtask, no scheduler.
- If `fn` returns a function, that cleanup runs **before the next run** and when the effect stops.
- The returned `stop()` ends the effect: it unsubscribes, drops a pending run and calls the cleanup.

In a ViewModel, `this.effect(fn)` registers the same thing, but it only runs **while a View using the
ViewModel is mounted**. It starts on mount and stops on unmount. See
[ViewModel and commands](../viewmodel/#lifecycle).

## `batch(fn)` → the value `fn` returns

Groups several writes so reactions run once, with the final state.

```ts
const saved = batch(() => {
  first.set("Grace");
  last.set("Hopper");
  return true;
});
```

Batches nest: reactions run when the outermost one ends. Reading inside a batch always gives the
latest values: computeds recalculate on read, they don't wait for the batch to end.

## `untracked(fn)` → the value `fn` returns

Runs `fn` without recording dependencies, even inside a computed or an effect.

```ts
effect(() => {
  // Re-runs when `query` changes, but not when `options` does.
  search(query.value, untracked(() => options.value));
});
```

For a single value, `x.peek()` does the same as `untracked(() => x.value)`.

## Guarantees

Each of these is covered by the runtime's tests.

- **Glitch-free.** Reactions never observe an intermediate state, even with diamond dependencies.
- **Push-pull.** Writes only mark dependents dirty; values are recalculated when read.
- **Synchronous.** After a write outside a batch, every reaction has already run.
- **Granular rendering.** Through `useBinding`, only the Views that read a value re-render, and not at
  all if the new value is `Object.is`-equal to the last one.
- **Concurrent-safe.** `useBinding` is built on React's `useSyncExternalStore`.
