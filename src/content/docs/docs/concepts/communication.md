---
title: Communication rules
description: How the View reads from and talks to the ViewModel, and why it never writes.
sidebar:
  order: 2
---

Dependencies point one way: `View ──▶ ViewModel ──▶ Model`. Data and actions travel along that line
with two mechanisms, and only those two.

## Reading: bindings

The ViewModel exposes **read-only** observables. The View subscribes with `useBinding`, which
re-renders the component when the value changes.

```ts
// ViewModel
readonly #filter = this.state<Filter>("all");
readonly filter = this.#filter.readonly;                // read-only view
readonly visible = this.computed(() => /* derived */);  // computeds are read-only
```

```tsx
// View
const filter = useBinding(vm.filter);
const visible = useBinding(vm.visible);
```

Reading `vm.filter.value` directly works once but does not subscribe: Bull warns about it
([MVVM206](../../rules/mvvm206/)).

## Acting: commands

The View never changes state. It asks the ViewModel to, through a command:

```ts
// ViewModel
readonly setFilter = this.command((filter: Filter) => this.#filter.set(filter));
readonly save = this.command(async () => this.repo.save(this.#draft.value), {
  canExecute: () => this.#draft.value.length > 0,
});
```

```tsx
// View
<button onClick={() => vm.setFilter.execute("done")}>Done</button>
<button onClick={vm.save.execute} disabled={!useBinding(vm.save.canExecute)}>Save</button>
```

Every command exposes its own observable state, so the View never needs logic for it:

| Member | Meaning |
|---|---|
| `execute(...args)` | Runs the action. It is bound, so it can be passed straight to `onClick`. |
| `isRunning` | `true` while an async command runs. |
| `canExecute` | `false` while running or when the `canExecute` option returns `false`. |
| `error` | The last error, or `undefined`. |

Assigning `vm.x = …` or calling `vm.x.set(…)` from a View is an error
([MVVM202](../../rules/mvvm202/)), and the runtime makes it impossible anyway: `.readonly` has no
`set`.

## Events stay in the View

DOM and React events are View details. Translate them to plain values before they reach the
ViewModel:

```tsx
<input value={draft} onChange={(e) => vm.editDraft.execute(e.target.value)} />
```

A ViewModel that receives a `MouseEvent` or touches `document` breaks [MVVM301](../../rules/mvvm301/).

## Talking back to the View

When the ViewModel needs the View to do something (navigate, focus, open a dialog), it exposes
state and lets the View react to it. The ViewModel never imports the View
([MVVM101](../../rules/mvvm101/)).
