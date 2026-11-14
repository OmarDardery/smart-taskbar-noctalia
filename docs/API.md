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
| Animation | Brief fade and optional paint-only icon scaling through the update interval; no bar frame-tick API, width changes, or perpetual loop |
| Clipping | Explicit main-axis root/viewport dimensions and `clip = true`, API 52 |
| Overflow | Discrete visible subset with whole-detent global `onScroll`; no unsupported `ui.scroll` |
| Drag order | Public `ui.dragSource/dropZone`, API 38; only in-widget model order, not compositor layout |
| Drag lifetime | No public bar drag-start/end callback. Manual-sort expansion stays open until clicked |
| Palette | Public theme roles including containers, API 43; the host repaints on palette changes |
| Icons | Cached public `appIconPath`, including host desktop matching; no icon subprocesses |
| Umbriel actions | `noctalia.umbriel.action`, API 45, `window-focus`, `window-close`, `window-minimize` as used by Noctalia's Umbriel backend |
| Events | API 54 native subscriptions when available; API 52/53 Umbriel uses public `runStream` and `umbriel subscribe windows workspaces` |
| niri actions | CLI argument arrays only on user action; no native niri action method exposed to plugins |
| Context menu | `panel.openContextMenu` is panel-only; no extra panel added for this single-widget release |
| Pin/unpin | Settings API is read-only. Pin lists are edited in normal widget settings |
| Middle click | Host default settings action retained; users must explicitly free the gesture before optional close/minimize callbacks |
| Workspace grouping | Representative app icon for workspace groups; window counts cover the full group |
| Settings editor | All controls are visible together in the host’s Widget section, ordered by topic; no unsupported section/group metadata |
| Empty state | `barWidget.setVisible(false)` hides the whole widget, while the event subscription stays active |
| Count badges | Numeric only, for counts above one; paint transforms overlay the icon corner without a layout lane |
| Manual persistence | In-memory per instance; no undocumented settings write or state file |

Version 0.1.1 requires API 52 for public container clipping. Native API 54 subscriptions are optional and used only after feature detection. On API 52/53, Umbriel events use its documented CLI through `runStream`, an existing public plugin API. Match the host’s reported API range instead of assuming every build with the same version label exposes identical capabilities. The user reported Noctalia v5.4.1 (`b096daa`) with API range 3–53; the published upstream v5.4.1 tag fetched separately reports an earlier API ceiling, so this compatibility claim is explicitly based on API level rather than all v5.4.1 packages.

## Compositor evaluation

Umbriel is implemented using window/workspace snapshots and typed native actions. Core `umbriel_workspace_backend.cpp` provides the reference field/action names; the plugin does not call the C++ backend or other private interfaces. Workspace-to-output mapping prefers workspace snapshot output and falls back to Umbriel's connector-prefixed workspace IDs. Scratchpads without a workspace are hidden, following the core taskbar.

On API 54+, niri is implemented with native `WindowsChanged`, `WindowOpenedOrChanged`, `WindowClosed`, `WindowFocusChanged`, `WorkspacesChanged`, and `WorkspaceActivated` events. Focus and close use `niri msg action ... --id`. Minimize is unavailable. Compositor integration has fixture coverage only.

Hyprland uses public socket2 events and socket1 JSON snapshots, subscribing before initial queries. Mango merges its public all-clients/all-monitors watches. Sway uses public i3 IPC subscriptions and event-triggered tree/workspace snapshots. These backends use a host-owned Python helper rather than unsupported native plugin subscriptions. See [COMPATIBILITY.md](COMPATIBILITY.md) for reviewed upstream sources and capabilities.

## Missing capability

Continuous pointer scrolling requires a native bar-compatible scroll viewport or continuous delta/offset API. Paint transforms and clipping alone do not provide native inertia or reliable pixel scrolling. The focused upstream request is prepared in [upstream-scroll-request.md](upstream-scroll-request.md). GitHub rejected issue creation with HTTP 403, so it has not been filed.

## API 52/53 Umbriel transport

The public [Umbriel IPC documentation](https://github.com/noctalia-dev/umbriel/blob/main/docs/user/ipc.md), reviewed at commit `33a782dc750e78f0ef2d21fd9d3df33229ae06f9`, specifies full snapshot subscriptions with initial state. Its CLI `umbriel subscribe windows workspaces` forwards newline-delimited event envelopes and explicitly flushes stdout after each line. `src/cli/ipc_client.cpp` and `src/main.cpp` confirm framing and command arguments.

`lib/transport.luau` uses one constant, non-interpolated shell program through public `runStream`. The shell runs the subscription, emits reset envelopes before/after connections, and waits two seconds before reconnecting after disconnection. A healthy stream performs no window queries and has no periodic subprocess work. No helper daemon or additional scripting runtime is needed; dependencies are the existing `umbriel` CLI and standard `sleep` utility. Native window actions remain `noctalia.umbriel.action` (API 45).

Noctalia’s process implementation creates a process group and cancels the group on `runStream` teardown. Because there is no individual public stream-stop method, compatibility-setting toggles detach delivery while retaining one connection and the latest full snapshots until reload/disable. Resuming replays snapshots without creating another stream. Host teardown owns shell, CLI and sleep cleanup. The real-pipe integration test verifies equivalent process-group termination with a fake CLI; actual Noctalia teardown still needs desktop acceptance.

The fallback never touches `noctalia.compositor` methods when the namespace is absent. On API 52/53, niri uses its documented JSON event stream. Hyprland, Mango and Sway use the same public socket helper on every supported plugin API level.

Version 0.1.2 adds optional hover magnification using public API 52 paint transforms. Cells reserve the maximum icon size, root extents remain bounded, and animation ends without an idle frame loop. Empty filtered results (including pin-only results with no matching running windows) hide the entire widget.

## Settings-section capability gap

Version 0.1.3 removes the page selector and conditional visibility from all plugin controls. `ManifestField` has no group, heading, or section member. `manifestSettingSpecs` assigns each plugin field the default `WidgetSettingPresentation.group = "widget"`. Built-in widget sections exist internally, but are not exposed through the public plugin schema. Adding an unrecognized `group` property would not create them. See [the focused upstream request](upstream-settings-sections-request.md).

The bridge chunks snapshots into sub-32-KiB JSON envelopes to respect the host stream-line bound. The Luau transport validates sequence and size and publishes only complete snapshots. CLI actions use argv arrays, validated compositor window IDs and a five-second timeout. Pinned launchers are detached so widget reload does not terminate launched applications.

Inline counts use supported row/column layout and theme roles. Group extents include badge dimensions; only duplicates reserve count space. Side bars stack inline counts under the icon. Wide counts fall back to inline layout to preserve the full numeric value. Focus reveal fits backwards from the target in one pass.
