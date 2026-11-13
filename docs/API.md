# Public API decisions

References were read before implementation on 2026-11-13:

- [Development](https://docs.noctalia.dev/noctalia/plugins/development/)
- [Manifest and settings](https://docs.noctalia.dev/noctalia/plugins/development/manifest/)
- [Entry scripts](https://docs.noctalia.dev/noctalia/plugins/development/entries/)
- [Declarative UI](https://docs.noctalia.dev/noctalia/plugins/development/declarative-ui/)
- [Runtime](https://docs.noctalia.dev/noctalia/plugins/development/runtime-api/)
- [API versions](https://docs.noctalia.dev/noctalia/plugins/development/plugin-api/)
- [Publishing workflow](https://docs.noctalia.dev/noctalia/plugins/development/workflow/)
- [Community repository](https://github.com/noctalia-dev/community-plugins), commit `0d394e250618b8409fee7a79dece9110d85d9062`
- [Official example](https://github.com/noctalia-dev/official-plugins/tree/main/example), repository commit `5dc1d19b1aa6be331ee6506034dc8448aca5c446`
- [Core source](https://github.com/noctalia-dev/noctalia), commit `42581ce5d3599be9cf54e971607c2d3ae43525fe`

| Feature | Public capability / decision |
| --- | --- |
| Manifest | Static `plugin.toml`, one `[[widget]]`, manifest settings; no QML |
| Modules | Relative Luau `require`, API 22 |
| Whole-widget hover | Native global `onHover(boolean)` exists, confirmed in official definitions and `plugin_widget.cpp`. The input dispatcher hovers the innermost target, so the widget also combines supported container/item hover callbacks to cancel spurious leave deadlines when crossing nested targets. |
| Item hover | Public `ui.row/column` `onHover`, string `"true"` / `"false"`; tracks action target and combines nested hover transitions without polling |
| Capsule accordion | Supported for host groups with multiple widgets; unnecessary with native whole-widget hover |
| Delays | Host update interval temporarily armed for pending deadlines, no pointer polling |
| Animation | Brief content fade via update interval; no bar frame-tick API. No width interpolation or perpetual loop |
| Clipping | Explicit main-axis root/viewport dimensions and `clip = true`, API 52 |
| Overflow | Discrete visible subset with whole-detent global `onScroll`; no unsupported `ui.scroll` |
| Drag order | Public `ui.dragSource/dropZone`, API 38; only in-widget model order, not compositor layout |
| Drag lifetime | No public bar drag-start/end callback. Manual-sort expansion stays open until clicked |
| Palette | Public theme roles including containers, API 43; the host repaints on palette changes |
| Icons | Cached public `appIconPath`, including host desktop matching; no icon subprocesses |
| Umbriel actions | `noctalia.umbriel.action`, API 45, `window-focus`, `window-close`, `window-minimize` as used by Noctalia's Umbriel backend |
| Events | `noctalia.compositor.subscribe/unsubscribe/name`, API 54; raw Umbriel and niri schemas |
| niri actions | CLI argument arrays only on user action; no native niri action method exposed to plugins |
| Context menu | `panel.openContextMenu` is panel-only; no extra panel added for this single-widget release |
| Pin/unpin | Settings API is read-only. Pin lists are edited in normal widget settings |
| Middle click | Host default settings action retained; users must explicitly free the gesture before optional close/minimize callbacks |
| Workspace grouping | Representative app icon for workspace groups; window counts cover the full group |
| Manual persistence | In-memory per instance; no undocumented settings write or state file |

The newest capability actually used is API 54, so `plugin_api = 54` is necessary. The official versions page labels API 44–54 unreleased. A generic “v5+ compatible” claim would be misleading; older stable releases cannot enable this plugin. There is no invented lower-API fallback.

## Compositor evaluation

Umbriel is implemented using window/workspace snapshots and typed native actions. Core `umbriel_workspace_backend.cpp` provides the reference field/action names; the plugin does not call the C++ backend or other private interfaces. Workspace-to-output mapping prefers workspace snapshot output and falls back to Umbriel's connector-prefixed workspace IDs. Scratchpads without a workspace are hidden, following the core taskbar.

niri is implemented with native `WindowsChanged`, `WindowOpenedOrChanged`, `WindowClosed`, `WindowFocusChanged`, `WorkspacesChanged`, and `WorkspaceActivated` events. Focus and close use `niri msg action ... --id`. Minimize is unavailable. Compositor integration has fixture coverage only.

Hyprland subscriptions are available, but provide string deltas and no initial snapshot or native plugin action method. Correct support needs an asynchronous, coalesced `hyprctl -j clients` / workspace snapshot reconciler, including reconnect races and address validation. This release deliberately declines that backend; it does not spawn repeated commands or pretend the normalized Umbriel schema applies to Hyprland. Sway/Mango/labwc/KDE subscriptions are not exposed by API 54 and also degrade to a placeholder.

## Missing capability

Continuous pointer scrolling requires a native bar-compatible scroll viewport or continuous delta/offset API. Paint transforms and clipping alone do not provide native inertia or reliable pixel scrolling. The focused upstream request is prepared in [upstream-scroll-request.md](upstream-scroll-request.md). GitHub rejected issue creation with HTTP 403, so it has not been filed.
