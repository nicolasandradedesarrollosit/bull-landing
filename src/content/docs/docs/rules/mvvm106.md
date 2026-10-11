---
title: "MVVM106 · Composition root imported"
description: "Nothing can import the composition root."
sidebar:
  label: "MVVM106 Composition root imported"
  order: 12
---

> **Dependency direction** · error · cannot be disabled · ESLint rule: `bull/imports-composition-root`

Nothing can import the composition root.

## Why

The composition root sits on top of everything: it knows all layers in order to wire them. If a layer imports it, that layer indirectly knows about all the others.

## How to fix

1. Remove the import. If you needed an instance, take it through the constructor and register it in the composition root.
