---
title: "Rule reference"
description: "Every Bull architecture rule, its severity and whether it can be disabled."
sidebar:
  label: Overview
  order: 0
---

Every rule has a stable code and an ESLint slug. Run `bull explain <code>` for the same text in your terminal.

| Code | Rule | Severity | Can be disabled |
|---|---|---|---|
| [MVVM001](./mvvm001/) | The project must have the src/model, src/viewmodel and src/view folders. | error | no |
| [MVVM002](./mvvm002/) | All code in src/ must belong to a layer (or be the composition root). | error | no |
| [MVVM003](./mvvm003/) | Each layer has its convention: *.model.ts, *.viewmodel.ts, *.view.tsx. | error | no |
| [MVVM004](./mvvm004/) | One of the layers has no files. | warning | yes |
| [MVVM005](./mvvm005/) | The composition root must exist (src/main.tsx by default). | error | no |
| [MVVM100](./mvvm100/) | The View can only depend on the ViewModel, never on the Model. | error | no |
| [MVVM101](./mvvm101/) | The ViewModel cannot know about the View. | error | no |
| [MVVM102](./mvvm102/) | The Model is the foundation: it cannot import ViewModels or Views. | error | no |
| [MVVM103](./mvvm103/) | The ViewModel is plain TypeScript: no React, JSX or hooks. | error | no |
| [MVVM104](./mvvm104/) | The Model cannot depend on React. | error | no |
| [MVVM105](./mvvm105/) | Some modules import each other in a circle. | error | no |
| [MVVM106](./mvvm106/) | Nothing can import the composition root. | error | no |
| [MVVM200](./mvvm200/) | The View does not access the network or storage. | error | no |
| [MVVM201](./mvvm201/) | State and effects live in the ViewModel, not in View hooks. | error | yes |
| [MVVM202](./mvvm202/) | The View never writes state: it asks the ViewModel to do it through commands. | error | no |
| [MVVM203](./mvvm203/) | Filtering, sorting or aggregating data is the job of a ViewModel computed. | warning | yes |
| [MVVM204](./mvvm204/) | ViewModels are obtained with useViewModel(), not with new. | error | no |
| [MVVM205](./mvvm205/) | The View can only import @bull-js/runtime/react, not the reactive primitives. | error | no |
| [MVVM206](./mvvm206/) | Reading `vm.x.value` in the View is not reactive: use useBinding(). | warning | yes |
| [MVVM300](./mvvm300/) | Every file in viewmodel/ exports a class that extends ViewModel. | error | no |
| [MVVM301](./mvvm301/) | The ViewModel does not access document, window, elements or DOM events. | error | no |
| [MVVM302](./mvvm302/) | The ViewModel's public surface is read-only: readonly state, computeds and commands. | error | no |
| [MVVM303](./mvvm303/) | One ViewModel per file, and the class is named after the file. | error | no |
| [MVVM304](./mvvm304/) | Repositories and services are injected through the constructor, not created with new. | error | no |
| [MVVM305](./mvvm305/) | Network and storage access belong in the Model. | error | yes |
| [MVVM400](./mvvm400/) | The Model does not use @bull-js/runtime: observable state is the ViewModel's business. | error | no |
| [MVVM401](./mvvm401/) | The Model does not know about the DOM. | error | no |
| [MVVM900](./mvvm900/) | bull.config.ts has an invalid value. | error | no |
| [MVVM901](./mvvm901/) | The file has a syntax error. | error | no |
