# [FEATURE] Public continuous scroll viewport for declarative bar widgets

Status: **not submitted**. GitHub issue creation against `noctalia-dev/noctalia` returned HTTP 403, `Resource not accessible by integration`, on 2026-11-13. This file is the ready-to-file issue body.

Bar plugins can render clipped `ui.row`/`ui.column` viewports (API 52) and receive whole-detent `onScroll(axis, steps, startsGesture)` callbacks, but `barWidget.render` rejects `ui.scroll`. This supports discrete pagination/virtualization, but not native continuous touchpad scrolling or scroll-to-focused behavior with pixel offsets.

Smart Taskbar implements the available fallback: a bounded virtualized icon strip with fixed logical-pixel extent, whole-gesture wheel navigation, and focus-triggered page reveal. No polling or private API is needed. A core primitive would improve this further.

Requested capability:

- A pointer-only, main-axis scroll viewport permitted in `barWidget.render`, without taking keyboard focus.
- Explicit viewport extent and clipping, with device scaling handled by the host.
- Continuous touchpad/wheel deltas, native gesture ownership, and host-managed offset/inertia or a documented pixel-offset interface.
- Keyed-child reveal for newly focused windows without resetting user scrolling on unrelated updates.
- Horizontal and vertical bar support; offscreen controls must not receive pointer input.
- Safe interaction with inline controls, gesture bindings, and in-widget drag-and-drop.

A minimal alternative is a declarative bar viewport with offset/revealKey and native wheel handling, rather than exposing raw frame-by-frame script animation.

References reviewed: plugin API versions (52, 54), Declarative UI / barWidget.render, Entry Scripts / onScroll, and current `plugin_widget.cpp` unsupported-control filtering. This request concerns continuous scrolling; discrete overflow navigation already works through supported controls. No private Noctalia interfaces or shell patches are required by the fallback.
