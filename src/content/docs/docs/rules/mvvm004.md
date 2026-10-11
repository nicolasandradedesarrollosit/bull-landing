---
title: "MVVM004 · Empty layer"
description: "One of the layers has no files."
sidebar:
  label: "MVVM004 Empty layer"
  order: 4
---

> **Structure** · warning · configurable · ESLint rule: `bull/empty-layer`

One of the layers has no files.

## Why

An empty layer usually means its responsibility is living somewhere else. For example, an empty viewmodel/ almost always means the View is managing state by itself.

## How to fix

1. Add at least one file to `the layer`, or review where that responsibility ended up.
