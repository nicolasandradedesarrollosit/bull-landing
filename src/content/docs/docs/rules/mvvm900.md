---
title: "MVVM900 · Invalid configuration"
description: "bull.config.ts has an invalid value."
sidebar:
  label: "MVVM900 Invalid configuration"
  order: 28
---

> **Configuration** · error · cannot be disabled · ESLint rule: `bull/invalid-config`

bull.config.ts has an invalid value.

## Why

Bull is strict on purpose: the structure and the direction of dependencies are not optional.

## How to fix

1. Check `the option` in bull.config.ts.
