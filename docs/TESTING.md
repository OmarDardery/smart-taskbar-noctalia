# Validation record

Executed on 2026-11-13 in the attached Linux cloud environment.

## Checks that actually ran

- **63 executable Luau fixture tests passed** (53 native/backend scenarios plus 10 API 52/53 compatibility tests). The harness executes the shipped model, compositor adapter, and widget entry with deterministic public host functions, event callbacks, UI constructors, and a simulated clock. It does not emulate native layout or real input delivery.
- **9,100 layout combinations** exercised within the width test: maximum extents 48–496 by 7, icon sizes 12–48 by 6, counts 0/1/5/16/100, and hover scales 1/1.05/1.15/1.5. Includes cross-field minimum width exceeding maximum width. Every computed root extent stayed within its maximum; capacity never became zero.
- Default side-bar tree width fits the standard 34-pixel bar; vertical main-axis extent is bounded. This is a tree assertion, not a rendered DPI check.
- **Official community manifest validation passed**, using exact community-pinned validator commit `99a892dc9cb3490634412701c45acd024fe0383b`.
- **All 178 tests of that official validator passed.** Those tests validate the validator, not Smart Taskbar's desktop behavior.
- All four shipped Luau files compiled with the official `luau-compile --null` command. Luau CLI commit: `f46d879e28302a430029304f7f6a162aed66f103`.
- Additional package checks verify custom catalog consistency, setting defaults/translations, the single-widget architecture, and required assets.
- **Two real-pipe shell integration tests passed** with fake Umbriel and niri CLIs: exact command arguments, JSON-line snapshot forwarding, reset on disconnect, two-second reconnect, no restarts while connected/idle, and child-process cleanup on process-group cancellation. This does not start a real compositor or Noctalia.
- The API 52/53 harness runs the actual entry with `noctalia.compositor` absent, covering startup, grouped actions, malformed lines, reconnect resets, cached replay without duplicate streams, missing commands, idle updates, and exit callback detachment.
- The fixture confirms 1,000 idle `update()` callbacks issue **zero renders and zero icon lookups**. This is not a CPU, memory, latency, or native idle-resource measurement.

## Author-reported desktop testing

The author reports testing on Umbriel. It is the only compositor tested on a real desktop. niri, Hyprland, Mango and Sway have automated fixture/protocol coverage only. No detailed per-scenario results were supplied, so the matrix below records the cloud agent’s checks and does not mark individual desktop scenarios passed.

## Acceptance matrix

“Fixture passed” below means executable logic coverage only. No row claims a live compositor test.

| Requested scenario | Executed evidence | Live desktop status |
| --- | --- | --- |
| Zero open applications | Entire widget hidden with zero children; first-window event restores it | Not run |
| One focused application | Focus state, hover delay, collapsed/expanded trees | Not run |
| Distinct running applications | 20-app fixture | Not run |
| Five windows of one app | One group, exact count 5, cycle to second window | Not run |
| More than 15 windows | 20-window fixture | Not run |
| Maximum-width overflow | Bounded root, clipped viewport, virtualized children; width combinations | Not run |
| Focus offscreen app | Reveals twentieth app; wheel offset persists through unrelated snapshots | Not run |
| Open/close/minimize/restore | Snapshot reconciliation, typed Umbriel action requests; niri close/focus argv | Not run |
| Workspace switches | Active/output filters; niri workspace event logic | Not run |
| Multiple monitors with different scaling | Two connector filters, per-instance output selection; scaling not tested | Not run |
| Top/bottom/left/right bars | Horizontal and vertical UI trees; native placement not tested | Not run |
| Theme and wallpaper changes | Role references reviewed against host palette-driven controls | Not run |
| Hover/wheel/touchpad/click | Direct callback tests, delay cancellation, gesture-start semantics | Not run with devices |
| Live settings and hot reload | `onConfigChanged` behavior and `onExit` unsubscribe fixture | Not run with host watcher |
| Noctalia/compositor restart | Reset clears stale state; fresh snapshot rebuilds | Not run with real restart |
| High DPI including 160% | No live rendering evidence | Not run |
| Responsiveness and idle resources | No idle render/icon work in fixture | Native measurements not run |
| Installation/enable/bar placement | Source shape, catalog and documented commands checked | Not run: no executable/session |

The environment has no `noctalia`, `umbriel`, `niri`, or `Hyprland` executable and no `/run/user` desktop session. Consequently `noctalia plugins lint`, config validation through the Noctalia executable, enabling, bar placement, native rendering/clipping, device gestures, and actual window actions were not run. Four committed visual assets are offline fixture previews with visible disclaimers and symbolic icons. They are not acceptance screenshots.

## Reproduce automated checks

Requires Python 3.11+ and the official Luau CLI:

```sh
LUAU=/path/to/luau python3 tests/run.py
/path/to/luau-compile --null smart-taskbar/widget.luau smart-taskbar/lib/model.luau smart-taskbar/lib/compositor.luau smart-taskbar/lib/transport.luau
python3 tests/stream_test.py
python3 scripts/check.py
```

For the exact canonical validator:

```sh
git clone https://github.com/noctalia-dev/official-plugins /tmp/smart-taskbar-validator
git -C /tmp/smart-taskbar-validator checkout 99a892dc9cb3490634412701c45acd024fe0383b
python3 -m venv /tmp/smart-taskbar-validator/.venv
/tmp/smart-taskbar-validator/.venv/bin/pip install -r /tmp/smart-taskbar-validator/.github/actions/validate-plugins/requirements.txt
/tmp/smart-taskbar-validator/.venv/bin/python -m unittest discover -s /tmp/smart-taskbar-validator/.github/actions/validate-plugins -p test_validate_plugins.py
/tmp/smart-taskbar-validator/.venv/bin/python /tmp/smart-taskbar-validator/.github/actions/validate-plugins/validate-plugins.py --profile community --root "$PWD"
```

The included GitHub Actions workflow runs manifest validation, compilation, fixture tests and package checks after publication. The initial remote run exposed a pip cache-path failure in the upstream composite action. The workflow now runs the same pinned canonical validator directly, without that cache wrapper.

## Required desktop acceptance before production

Use a Noctalia API 52+ build and Umbriel. Test both the CLI transport on API 52/53 and native subscriptions on API 54+. Install the local path source, enable the plugin, add `omardardery/smart-taskbar:taskbar`, and set bar/widget scale to 1, host capsule off, capsule padding 0, and no custom label/group wrapper. Create the windows listed above and confirm the native widget extent never exceeds 420 logical pixels. Record the exact Noctalia and compositor versions and capture actual screenshots of all four states.

Repeat on top, bottom, left and right bars, then at 100%, 160%, and mixed monitor scaling. Check real icon loading, pointer movement across inline cells, hover delays, touchpad direction changes, menu/settings precedence, and dragging past widget boundaries. Change every settings category while running, reload the Luau module, restart the compositor, and restart Noctalia. Repeat focus/close on niri; verify its unavailable minimize action reports gracefully.

Use the Noctalia build's `noctalia plugins lint` help for the current lint invocation and run its config validator against the installed configuration. Measure idle CPU/RSS and focus-to-highlight latency with the actual shell; investigate warnings rather than suppressing them. Mark each desktop row only after recording its result. Keep the community PR draft until these checks and real screenshots are complete.

Version 0.1.2 is intended for the user-reported API 3–53 desktop and declares minimum API 52. It has no direct native-desktop test result yet. The original 0.1.0 API 54 compatibility gate was confirmed to prevent enabling there; this update replaces that event-transport requirement with a tested public CLI fallback.

Version 0.1.2 regression coverage includes last-window hiding/recovery, filtered and pin-only empty states, no singleton count/placeholder node, numeric corner badges, bounded hover scaling without repeated icon lookup, reduced motion, side-bar magnification, collapsed duplicate counts, animation cancellation while hidden, and settings-page changes without redraw/cache invalidation. The 0.1.2 page selector was subsequently removed in 0.1.3. Current manifest checks require all plugin controls to be simultaneously visible, with no page selector, visibility condition, or advanced flag. These tests do not establish native desktop acceptance.

Release 0.1.2 source CI run `43502864159` and community validation run `43502880213` passed on GitHub. Native desktop acceptance is still separate from these automated results.

Version 0.1.3 package checks confirm every plugin control is exposed on the same host editor page. Labels retain no category prefix. Runtime tests retain coverage that saved legacy editor values do not reset expansion or icons. Native accordion section layout is not supported by the current public manifest API.

## Multi-compositor release candidate

14 Python bridge tests passed: 11 normalization/framing tests and three integration tests that execute the shipped helper against actual local UNIX socket fixtures for Hyprland, Mango and Sway. These cover public wire framing, initial subscription, event updates, reconnect, geometry deduplication, burst coalescing and no idle queries. Socket tests required sandbox escalation in this environment. They do not run real compositors.

Additional Luau tests cover niri urgency, ignored geometry/layout changes, atomic chunk assembly, cached replay, Mango multi-tag filters, stable workspace icons, missing application IDs and targeted CLI argument validation/timeouts. Idle callbacks neither render nor rearm the update timer. Reproduce bridge checks with `PYTHONDONTWRITEBYTECODE=1 python3 tests/bridge_test.py`; reproduce shell checks with `python3 tests/stream_test.py`.

Repeat the full desktop matrix separately under Umbriel, niri, Hyprland, Mango and Sway before claiming production desktop acceptance. Python/socket fixture results do not establish actual window actions, monitor scaling or resource measurements.

## Version 1.1.0 appearance regression checks

Eight additional executable checks cover inline capsule counts, placement changes and disabled counts, narrow side bars, mixed-width overflow and focus reveal, 3,250 mixed-width layout budgets across both orientations, proportional multi-digit overlays, readable fallback for small icons, and hover feedback without magnification. All 63 Luau fixture tests passed. Updated grouped previews show the inline mode and remain explicitly labeled offline fixtures. These new appearance changes have not yet been rechecked on the author's Umbriel desktop.

Version 1.1.1: inline counts have no independent fill, border or radius and use the shared app capsule contrast role. The 63 Luau checks pass, including assertions for the unified appearance. Desktop recheck remains pending.

Version 1.1.2 adds an inline count appearance selector. All 64 Luau checks pass; the new regression verifies live plain/bubble changes preserve geometry and leave overlay bubbles intact. Native desktop recheck remains pending.
