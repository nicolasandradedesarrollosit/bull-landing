---
title: ViewModel and commands
description: The ViewModel base class, its helpers, its lifecycle and the Command type.
sidebar:
  order: 1
---

```ts
import { ViewModel } from "@bull-js/runtime";

export class CheckoutViewModel extends ViewModel {
  readonly #items = this.state<CartItem[]>([]);

  readonly items = this.#items.readonly;
  readonly total = this.computed(() => sum(this.#items.value.map((i) => i.price)));
  readonly pay = this.command(async () => this.payments.charge(this.total.value), {
    canExecute: () => this.#items.value.length > 0,
  });

  constructor(
    private readonly cart: CartRepository,
    private readonly payments: PaymentService,
  ) {
    super();
  }

  protected override onActivate() {
    void this.load.execute();
  }

  readonly load = this.command(async () => this.#items.set(await this.cart.items()));
}
```

## Helpers

| Helper | Returns | Use it for |
|---|---|---|
| `this.state(initial)` | `State<T>` | Private, mutable state. Expose it with `.readonly`. |
| `this.computed(fn)` | `Computed<T>` | Derived data: filtering, sorting, totals. |
| `this.command(fn, options?)` | `Command<A, R>` | Every action the View can trigger. |
| `this.effect(fn)` | `void` | Reactions that run while the View is mounted. |

These are the primitives from [the reactivity model](../../concepts/reactivity/), created on the
ViewModel. Effects are the exception: they are tied to its lifecycle.

## Lifecycle

`useViewModel` creates the ViewModel once per component and **activates** it on mount:

- `onActivate()` runs. Load initial data here. It may return a cleanup function.
- Effects registered with `this.effect()` start.

On unmount the ViewModel is **deactivated**: effects stop and cleanups run. Activation is
reference-counted, so React StrictMode's double mount is safe. `vm.isActive` tells whether it is
currently active.

An effect that keeps something in sync while the screen is open:

```ts
export class SearchViewModel extends ViewModel {
  readonly #query = this.state("");
  readonly #results = this.state<Result[]>([]);
  readonly query = this.#query.readonly;
  readonly results = this.#results.readonly;
  readonly type = this.command((text: string) => this.#query.set(text));

  constructor(private readonly api: SearchService) {
    super();
    // Runs on mount and on every change to the query; the cleanup cancels the previous request.
    this.effect(() => {
      const controller = new AbortController();
      this.api.search(this.#query.value, controller.signal).then((r) => this.#results.set(r));
      return () => controller.abort();
    });
  }
}
```

## `Command<A, R>`

```ts
readonly rename = this.command((name: string) => this.#name.set(name));
readonly save = this.command(async () => this.repo.save(this.#draft.value));
```

| Member | Type | Meaning |
|---|---|---|
| `execute(...args: A)` | `R \| undefined`, or a `Promise` for async commands | Runs the action. Bound, so it can be passed to `onClick`. Returns `undefined` when it cannot run or fails. |
| `isRunning` | `ReadonlyState<boolean>` | `true` while an async command runs. |
| `canExecute` | `ReadonlyState<boolean>` | `false` while running or when `options.canExecute()` is `false`. Reactive. |
| `error` | `ReadonlyState<unknown>` | The last error; cleared on the next execution. Errors are also logged. |

An async command cannot run twice at the same time: `execute` returns `undefined` while
`isRunning` is `true`, which prevents double submits.

Errors never escape a command. A synchronous throw or a rejected promise ends up in `error` (and in
the console), `execute` returns `undefined`, and the next execution clears it.

### Why commands

The View never writes state ([MVVM202](../../rules/mvvm202/)), so commands are how it asks for
something. Each one is a named action in the ViewModel, so every change has one place where it
happens, is validated and is tested. Loading, errors and "can I click this?" come with it as reactive
values, so the View holds no logic of its own:

```tsx
const canSave = useBinding(vm.save.canExecute);
const saving = useBinding(vm.save.isRunning);

<button onClick={vm.save.execute} disabled={!canSave}>
  {saving ? "Saving…" : "Save"}
</button>
```

A command's body is not batched automatically: if it writes several states that belong together,
wrap the writes in [`batch`](../reactivity/#batchfn--the-value-fn-returns).

## Destructuring in the View

Every public member is a field (a read-only state, a computed or a command), and `execute` is bound
to its command, so a View can destructure the ViewModel:

```tsx
const { total, pay } = useViewModel(CheckoutViewModel);
const amount = useBinding(total);

<button onClick={pay.execute}>Pay {amount}</button>
```

The rules follow destructured members, aliases and nested patterns: `total.value` still warns
([MVVM206](../../rules/mvvm206/)).

## The rules that apply

- It must extend `ViewModel` ([MVVM300](../../rules/mvvm300/)) and be named after its file
  ([MVVM303](../../rules/mvvm303/)).
- Public members are read-only ([MVVM302](../../rules/mvvm302/)): `readonly` fields, `.readonly`
  state, computeds and commands. `bull fix` can repair this one.
- Dependencies come through the constructor ([MVVM304](../../rules/mvvm304/)).
