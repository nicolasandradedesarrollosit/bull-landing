---
title: ViewModel and commands
description: The ViewModel base class, its helpers, its lifecycle and the Command type.
sidebar:
  order: 1
---

```ts
import { ViewModel } from "@bull/runtime";

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

## Lifecycle

`useViewModel` creates the ViewModel once per component and **activates** it on mount:

- `onActivate()` runs. Load initial data here. It may return a cleanup function.
- Effects registered with `this.effect()` start.

On unmount the ViewModel is **deactivated**: effects stop and cleanups run. Activation is
reference-counted, so React StrictMode's double mount is safe. `vm.isActive` tells whether it is
currently active.

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

## The rules that apply

- It must extend `ViewModel` ([MVVM300](../../rules/mvvm300/)) and be named after its file
  ([MVVM303](../../rules/mvvm303/)).
- Public members are read-only ([MVVM302](../../rules/mvvm302/)): `readonly` fields, `.readonly`
  state, computeds and commands. `bull fix` can repair this one.
- Dependencies come through the constructor ([MVVM304](../../rules/mvvm304/)).
