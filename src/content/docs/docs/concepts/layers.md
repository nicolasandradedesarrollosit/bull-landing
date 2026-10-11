---
title: The three layers
description: What belongs in the Model, the ViewModel and the View, and how files are named.
sidebar:
  order: 1
---

Every file in `src/` belongs to exactly one layer. The folder decides the layer, the file name
says the role.

```
src/
├── model/       *.model.ts · *.entity.ts · *.repository.ts · *.service.ts · *.types.ts
├── viewmodel/   *.viewmodel.ts
├── view/        *.view.tsx
└── main.tsx     the composition root
```

Folders listed in `allowDirs` (by default `assets` and `styles`) can hold non-layer files such as
images and CSS. A loose `utils/` or `hooks/` folder is an error ([MVVM002](../../rules/mvvm002/)):
it would let any layer reach anything.

## Model

The domain: entities, business rules and data access. It is the only layer that does I/O.

```ts
// src/model/todo.repository.ts
export class TodoRepository {
  async list(): Promise<Todo[]> {
    return (await fetch("/api/todos")).json();
  }
}
```

| May | Never |
|---|---|
| Import other Models and domain libraries | Import ViewModels or Views ([MVVM102](../../rules/mvvm102/)) |
| Use `fetch`, storage, IndexedDB | Import React ([MVVM104](../../rules/mvvm104/)) or `@bull/runtime` ([MVVM400](../../rules/mvvm400/)) |
| | Touch the DOM ([MVVM401](../../rules/mvvm401/)) |

## ViewModel

The state and actions of one screen, as a plain TypeScript class that extends `ViewModel`.
It knows the Model and nothing above it.

```ts
// src/viewmodel/todo-list.viewmodel.ts
export class TodoListViewModel extends ViewModel {
  readonly #todos = this.state<Todo[]>([]);
  readonly todos = this.#todos.readonly;
  readonly pending = this.computed(() => this.#todos.value.filter((t) => !t.done).length);
  readonly load = this.command(async () => this.#todos.set(await this.repo.list()));

  constructor(private readonly repo: TodoRepository) {
    super();
  }
}
```

| May | Never |
|---|---|
| Import the Model and `@bull/runtime` | Import React, `react-dom` or contain JSX ([MVVM103](../../rules/mvvm103/)) |
| Receive dependencies through the constructor | Create repositories with `new` ([MVVM304](../../rules/mvvm304/)) |
| Expose read-only state, computeds and commands | Expose mutable state ([MVVM302](../../rules/mvvm302/)) |
| | Touch the DOM ([MVVM301](../../rules/mvvm301/)) or do I/O directly ([MVVM305](../../rules/mvvm305/)) |

One ViewModel per file, named after it: `todo-list.viewmodel.ts` exports `TodoListViewModel`
([MVVM303](../../rules/mvvm303/)).

## View

React components that read the ViewModel and call its commands. They own no state.

```tsx
// src/view/todo-list.view.tsx
export function TodoListView() {
  const vm = useViewModel(TodoListViewModel);
  const todos = useBinding(vm.todos);
  return <TodoItems todos={todos} onReload={vm.load.execute} />;
}
```

| May | Never |
|---|---|
| Import ViewModels, other Views and `@bull/runtime/react` | Import the Model ([MVVM100](../../rules/mvvm100/)) |
| Use `useViewModel`, `useBinding`, `useRef`, `useId` | Use `useState`, `useEffect`, `useMemo` ([MVVM201](../../rules/mvvm201/)) |
| Receive data and callbacks through props | Fetch or store data ([MVVM200](../../rules/mvvm200/)) |
| | Write to the ViewModel ([MVVM202](../../rules/mvvm202/)) |

A View can also be purely presentational: it takes props and renders, without a ViewModel.
