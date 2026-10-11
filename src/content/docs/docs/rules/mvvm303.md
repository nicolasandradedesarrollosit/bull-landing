---
title: "MVVM303 · Wrong ViewModel name"
description: "One ViewModel per file, and the class is named after the file."
sidebar:
  label: "MVVM303 Wrong ViewModel name"
  order: 23
---

> **ViewModel** · error · cannot be disabled · ESLint rule: `bull/viewmodel-per-file`

One ViewModel per file, and the class is named after the file.

## Why

Finding a View's ViewModel must be trivial: `todo-list.view.tsx` uses `TodoListViewModel`, which lives in `todo-list.viewmodel.ts`. With several classes per file that correspondence is lost.

## How to fix

1. Split each ViewModel into its own `*.viewmodel.ts` file.
