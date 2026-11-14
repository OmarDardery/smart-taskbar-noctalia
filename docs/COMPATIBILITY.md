# Compositor compatibility

Minimum Noctalia plugin API: **52**. Version 1.0.0 is a release candidate; all adapters have automated fixture coverage, and none has a recorded live desktop acceptance result in this environment.

| Compositor | Event transport | Focus/close | Minimize/restore | Notes |
| --- | --- | --- | --- | --- |
| Umbriel | Native API 54+; public CLI stream on API 52/53 | Native host actions | Native minimize; focus restores | Primary adapter; workspace/output snapshots |
| niri | Native API 54+; JSON CLI stream on API 52/53 | `niri` CLI | Unavailable | Includes urgency and workspace events |
| Hyprland | Public socket2 events plus socket1 JSON queries | `hyprctl` CLI | Unavailable | Subscribes before snapshots; coalesces relevant events |
| Mango | Public all-clients/all-monitors socket watches | `mmsg` targeted client dispatch | Targeted minimize; focus restores | Multi-tag membership counts each window once |
| Sway | Public i3 IPC subscription/tree/workspaces | `swaymsg` targeted con_id | Unavailable | Floating/Xwayland windows included; hidden scratchpad excluded |
| Other | Unavailable | Unavailable | Unavailable | Widget stays hidden; no invented private integration |

Hyprland, Mango and Sway require Python 3.9+ with only its standard library. Each widget instance owns one helper. Umbriel/niri older-shell fallbacks own one CLI stream. No helper queries on a timer, starts per-icon processes, writes state or accesses the network. Hyprland/Sway snapshot queries follow relevant compositor events, with a 25ms coalescing window and 100ms maximum burst delay. Socket reconnect backoff is 1–30 seconds. Native layout/DPI/input and actual compositor restarts still need desktop validation.

Application identities remain exact for matching, while titles are normalized and bounded for display. Snapshots are deduplicated using UI-relevant fields, preserving stable identities/order. Bridge snapshots are chunked below the host line-buffer limit and applied atomically. Actions validate IDs, use argv arrays and time out after five seconds. Unsupported minimize actions report unavailable rather than moving windows into scratchpads.

## Public sources reviewed

- [Umbriel IPC](https://github.com/noctalia-dev/umbriel/blob/33a782dc750e78f0ef2d21fd9d3df33229ae06f9/docs/user/ipc.md): snapshots and public actions.
- [niri IPC definitions](https://github.com/YaLTeR/niri/blob/73a04441fccc78294c3899af8f8cdd2a1e38fa33/niri-ipc/src/lib.rs): initial events, deltas, focus and urgency.
- [Hyprland IPC implementation](https://github.com/hyprwm/Hyprland/blob/0767f6347a69607638a4f93b3cd613af15a121e0/src/ipc/s1/Commands.cpp): legacy/current workspace addresses and JSON query fields; public socket2 events.
- [Mango IPC documentation](https://github.com/mangowm/mango/blob/ba0c8d9859f9142d1cfcc61f39f289c545661fb9/docs/ipc.md): watch snapshots and client-targeted dispatch; checked against src/ipc/ipc.c.
- [Sway IPC manual](https://man.archlinux.org/man/sway-ipc.7.en): i3 framing, subscription and tree/workspace queries.

No compositor source is patched or imported. A compositor version lacking the documented protocol may require an update. Automatic detection uses the native host name or compositor socket environment; explicit compatibility selection is a safety restriction, not a way to connect to another session.
