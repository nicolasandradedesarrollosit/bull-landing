---
title: Reactivity, from the inside
description: How Bull's signals work, how they reach React, why commands exist, and what replaces each React hook.
sidebar:
  order: 1.5
---

Reactivity is the heart of Bull. Every screen's state lives in a ViewModel as **signals**: values
that know who reads them and tell those readers when they change. React still renders everything,
but it no longer owns the state. This page explains the model end to end; the
[API reference](../../runtime/reactivity/) lists every method.

## Why not React state?

With `useState`, state lives inside a component. To test the logic you have to render it, to share
it you lift it up or put it in context, and every change re-renders the component that owns it and
everything below.

Bull moves state into a plain class:

```ts
export class CartViewModel extends ViewModel {
  readonly #items = this.state<Item[]>([]);
  readonly items = this.#items.readonly;
  readonly total = this.computed(() => sum(this.#items.value.map((i) => i.price)));
  readonly add = this.command((item: Item) => this.#items.update((list) => [...list, item]));
}
```

That class runs anywhere: in a test with `new CartViewModel()`, in a Node script, or behind any View.
React's only job is to draw it.

## The three primitives

| Primitive | What it is | Inside a ViewModel |
|---|---|---|
| **state** | A value you can read and write. The source of truth. | `this.state(initial)` |
| **computed** | A value derived from others. Recalculated only when they change. | `this.computed(() => …)` |
| **effect** | Code that runs again whenever what it read changes. | `this.effect(() => …)` |

Plus two that build on them: **commands**, for the actions a View can trigger, and `useBinding`, for
reading a value from a View.

## Reading is subscribing

There are no dependency arrays. When a computed or an effect runs, every `.value` it reads is
recorded as a dependency. When one of those values changes, Bull knows exactly who to tell.

```ts
const price = state(10);
const quantity = state(2);
const total = computed(() => price.value * quantity.value); // depends on price and quantity

effect(() => console.log(`Total: ${total.value}`));         // depends on total
// Total: 20

quantity.set(3);
// Total: 30
```

The result is a graph:

```
price ────┐
          ├──▶ total ──▶ effect (console.log)
quantity ─┘                └──▶ CartView (useBinding)
```

To read without subscribing, use `peek()`, or wrap the read in `untracked(() => …)`.

### Dependencies follow the code that actually ran

Dependencies are recorded on every run, so they follow the branches your code takes:

```ts
const showFull = state(true);
const label = computed(() => (showFull.value ? fullName.value : initials.value));
```

While `showFull` is `true`, `label` depends on `showFull` and `fullName`, and changing `initials`
does nothing. Flip `showFull` and the dependencies switch on the next run.

## Push, then pull

Writes and reads do different amounts of work:

1. **Push.** `set()` doesn't recalculate anything. It marks the computeds that depend on the value
   as *dirty*, and those mark their own dependents, down the graph.
2. **Pull.** A dirty computed recalculates the next time someone reads it, and only then. A computed
   nobody reads costs nothing.

```ts
const expensive = computed(() => slowSort(list.value));
list.set(bigList);   // nothing sorted yet
list.set(otherList); // still nothing
expensive.value;     // sorted once, with otherList
expensive.value;     // cached: not sorted again
```

## No glitches

Take a "diamond": two computeds that depend on the same states, read by one effect.

```ts
const first = state("Ada");
const last = state("Lovelace");
const full = computed(() => `${first.value} ${last.value}`);
const initials = computed(() => `${first.value[0]}${last.value[0]}`);

effect(() => console.log(`${full.value} (${initials.value})`));
// Ada Lovelace (AL)

batch(() => {
  first.set("Grace");
  last.set("Hopper");
});
// Grace Hopper (GH)
```

The effect never sees `Grace Lovelace`, or a new `full` with old `initials`. Reactions (effects and
subscribers, which includes your Views) wait in a queue until the writes are done, and by then every
computed they read is up to date. This is what "glitch-free" means.

### batch

Each `set()` is already atomic. Wrap **several** writes in `batch` when they belong together, so
reactions run once with the final state instead of once per write. Batches can be nested: reactions
run when the outermost one ends. `batch` returns whatever its function returns.

A command's body does not batch automatically. If a command writes several states, wrap the writes
in `batch`.

### Reactions are synchronous

There is no scheduler or microtask: after a `set()` outside a batch, every reaction has already run
by the next line. That makes tests simple, because you write, then assert. React then decides when
to paint, as it always does.

## Equality and immutability

`set()` ignores a value that is `Object.is`-equal to the current one: nothing is notified. Two
consequences:

- Setting the same number or string twice is free.
- **Mutating an object or array in place is invisible.** Same reference, so nothing changed as far
  as Bull can tell.

```ts
// ✗ Nothing re-renders: it is still the same array
this.#items.peek().push(item);

// ✓ A new array: every reader is notified
this.#items.update((list) => [...list, item]);
```

Treat state as immutable: replace arrays and objects, don't modify them.

## How it reaches React

A View reads a signal with `useBinding`:

```tsx
export function CartView() {
  const vm = useViewModel(CartViewModel);
  const total = useBinding(vm.total);
  return <p>Total: {total}</p>;
}
```

Under the hood, `useBinding` is React's own
[`useSyncExternalStore`](https://react.dev/reference/react/useSyncExternalStore), the official way
for a component to subscribe to data that lives outside React. Three things follow:

- **Only the Views that read a value re-render.** Change `vm.left` and a View that only binds
  `vm.right` is not touched: no parent re-render, no context fan-out, no `memo` needed.
- **Same value, no render.** React compares snapshots with `Object.is`. If a computed recalculates
  to the same result (a parity flag that stays `true`, say), the View does not re-render.
- **It is safe with concurrent rendering and StrictMode**, because that is what
  `useSyncExternalStore` was built for.

Never read `.value` in a View. It gives you the value once and never updates the component
([MVVM206](../../rules/mvvm206/)).

## Lifecycle: effects run while someone is looking

`this.effect()` in a ViewModel does not start when the class is created. It starts when a View using
the ViewModel **mounts**, and stops when the last one **unmounts**. The same goes for
`onActivate()`, the place to load initial data:

```ts
export class ClockViewModel extends ViewModel {
  readonly #now = this.state(new Date());
  readonly now = this.#now.readonly;

  protected override onActivate() {
    const id = setInterval(() => this.#now.set(new Date()), 1000);
    return () => clearInterval(id); // runs on unmount
  }
}
```

Activation is reference-counted, so React StrictMode's double mount, or two Views sharing one
ViewModel, start and stop everything exactly once.

## Commands: how the View acts

The View never writes state. To make something happen, it calls a **command** the ViewModel
exposes. A command is an action that carries its own reactive state:

| Member | What it gives the View |
|---|---|
| `execute(...args)` | Runs the action. Already bound, so `onClick={vm.save.execute}` works, even after destructuring. |
| `isRunning` | `true` while an async command runs. |
| `error` | The last error, caught for you. Cleared on the next run. |
| `canExecute` | `false` while running, or when your own condition says no. `execute` does nothing then. |

```ts
export class SignupViewModel extends ViewModel {
  readonly #email = this.state("");
  readonly email = this.#email.readonly;

  readonly editEmail = this.command((value: string) => this.#email.set(value));
  readonly submit = this.command(async () => this.accounts.create(this.#email.value), {
    canExecute: () => this.#email.value.includes("@"),
  });

  constructor(private readonly accounts: AccountService) {
    super();
  }
}
```

```tsx
export function SignupView() {
  const vm = useViewModel(SignupViewModel);
  const email = useBinding(vm.email);
  const canSubmit = useBinding(vm.submit.canExecute);
  const sending = useBinding(vm.submit.isRunning);
  const error = useBinding(vm.submit.error);

  return (
    <form onSubmit={(e) => { e.preventDefault(); vm.submit.execute(); }}>
      <input value={email} onChange={(e) => vm.editEmail.execute(e.target.value)} />
      <button disabled={!canSubmit}>{sending ? "Sending…" : "Sign up"}</button>
      {error ? <p role="alert">Could not sign up.</p> : null}
    </form>
  );
}
```

**Why commands exist:**

- **One way to change state.** Every change goes through a named action in the ViewModel, where it
  can be validated and tested.
- **No ceremony in the View.** No `useState(loading)`, no `try/catch`, no `disabled={loading || !valid}`
  logic. The View reads `isRunning`, `error` and `canExecute` like any other value.
- **No double submits.** While an async command runs, `canExecute` is `false` and `execute` returns
  `undefined` without running again.
- **It is MVVM's own idea**: WPF's `ICommand`, and the functions Knockout views call.

## React hooks in Bull

Bull doesn't replace React's hooks; it decides who may use them. Everything that is **state or logic**
belongs to the ViewModel, so the View may not use those hooks ([MVVM201](../../rules/mvvm201/)).
Everything that is **purely about rendering** stays allowed.

| Hook | In a View | Use instead / why |
|---|---|---|
| `useState`, `useReducer` | ✗ | `this.state()` in the ViewModel, read with `useBinding`. |
| `useMemo` | ✗ | `this.computed()`: derived data is logic. |
| `useEffect`, `useLayoutEffect`, `useInsertionEffect` | ✗ | `this.effect()` or `onActivate()`, which follow the View's lifecycle. |
| `useActionState`, `useOptimistic` | ✗ | A command: `isRunning`, `error`, `canExecute`. |
| `useSyncExternalStore` | ✗ | `useBinding`, which is exactly this, wired to signals. |
| `useCallback` | ✓ | Rarely needed: `execute` is already a stable, bound function. |
| `useRef` | ✓ | DOM references, such as focusing an input. |
| `useContext` | ✓ | Visual context, such as a theme. |
| `useId` | ✓ | Ids for accessibility. |
| `useTransition`, `useDeferredValue` | ✓ | Rendering priorities. |
| `useImperativeHandle`, `useDebugValue`, `use` | ✓ | Component plumbing. |

For purely visual state, like whether a dropdown is open, you can allow a hook explicitly:

```ts
// bull.config.ts
export default defineConfig({ view: { allowHooks: ["useState"] } });
```

React's state hooks are still used, inside the runtime and only there
(`@bull-js/runtime/react`): `useState` holds each component's ViewModel instance, `useEffect` activates
and deactivates it, `useContext` reaches the dependency container, and `useSyncExternalStore` powers
`useBinding`.

## From Knockout to Bull

If you have used Knockout.js, the model is the same, with types and without bindings in the HTML:

| Knockout | Bull |
|---|---|
| `ko.observable(0)` | `this.state(0)` |
| `ko.pureComputed(() => …)` | `this.computed(() => …)` |
| `observable.subscribe(fn)` | `this.effect(() => …)` |
| `data-bind="text: total"` | `const total = useBinding(vm.total)` in JSX |
| a function the view calls | `this.command(…)` with `isRunning`, `error` and `canExecute` |
| `ko.applyBindings(vm)` | `useViewModel(CartViewModel)`, with dependencies injected |

## Common mistakes

| Mistake | What happens | Do this |
|---|---|---|
| Reading `vm.total.value` in a View | Shows the value once and never updates. Warned as [MVVM206](../../rules/mvvm206/). | `useBinding(vm.total)` |
| `list.push(x)` on state | Nothing re-renders. | `update((l) => [...l, x])` |
| Exposing the `State` itself | The View could write it. Error [MVVM302](../../rules/mvvm302/). | Keep it private (`#items`) and expose `.readonly`. |
| `peek()` inside a computed | It won't recalculate when that value changes. | Use `.value` unless you mean it. |
| Setting several states one by one | Reactions run once per write. | Wrap the writes in `batch`. |

Destructuring the ViewModel is fine: `const { total, add } = useViewModel(CartViewModel)` works, and
the rules still check what you do with `total` and `add`.
