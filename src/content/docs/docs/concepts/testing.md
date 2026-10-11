---
title: Testing ViewModels
description: ViewModels are plain classes, so they are tested without React or a DOM.
sidebar:
  order: 4
---

Because a ViewModel never imports React or the DOM, its test is a regular unit test: build it with a
fake or in-memory dependency, call commands, read values.

```ts
import { describe, expect, it } from "vitest";
import { TodoRepository } from "../model/todo.repository";
import { TodoListViewModel } from "./todo-list.viewmodel";

describe("TodoListViewModel", () => {
  it("adds a valid task and clears the draft", () => {
    const vm = new TodoListViewModel(new TodoRepository(memoryStorage(), 0));
    vm.editDraft.execute("  Buy bread ");
    vm.add.execute();
    expect(vm.visible.value.map((t) => t.title)).toEqual(["Buy bread"]);
    expect(vm.draft.value).toBe("");
  });

  it("rejects invalid titles and explains why", () => {
    const vm = new TodoListViewModel(new TodoRepository(memoryStorage(), 0));
    vm.add.execute();
    expect(vm.draftError.value).toBe("Write something to add.");
  });
});
```

Tips:

- Inject the Model through the constructor ([MVVM304](../../rules/mvvm304/)), and a test can pass an
  in-memory version.
- `await vm.someCommand.execute()` waits for async commands; `vm.someCommand.error.value` holds a
  failure.
- `onActivate()` and `this.effect()` only run while a View is mounted. In a test, call the command
  that `onActivate` would call.

`bull g viewmodel <name>` and `bull g feature <name>` generate a `*.viewmodel.test.ts` next to the
ViewModel when Vitest is installed. Test files are ignored by the architecture rules.
