<!-- noctalia-pr-template:v1 -->

## Plugin

- **Id:** `omardardery/smart-taskbar`
- [x] New plugin
- [ ] Update to an existing plugin (version bumped in `plugin.toml`)

## What it does

Smart Taskbar is one API 52+ Luau bar widget with stable collapsed extent, grouped numeric counts, supported hover expansion, click/always modes, and a bounded 420-logical-pixel default expanded extent. Overflow uses a clipped virtualized icon strip with wheel navigation and focus reveal. Umbriel is the primary adapter; niri receives events natively and uses its CLI on explicit focus/close actions.

Empty states hide the entire widget. Single-window apps have no count marker or placeholder lane; duplicates show numeric corner badges only. Optional hover enlargement uses paint transforms in fixed cells, and all settings are visible together in the main Widget editor, with related fields adjacent and no page selector.

Manual drag ordering stays within the widget and is in-memory. In manual mode expansion stays open until explicitly clicked because the public API lacks drag-start/end callbacks. Right click opens settings because native context menus are panel-only. Pin lists are settings-driven because configuration is read-only. Version 0.1.3 supports Umbriel on API 52/53 through its public CLI event stream; API 54+ uses native subscriptions. The host’s API range is authoritative.

**Desktop acceptance remains pending.** The cloud environment has no Noctalia/compositor executable/session. Native installation, compositor actions, screenshots, device gestures, scaling and resource measurements are pending. The visual assets are clearly labeled offline fixture previews, not live screenshots.

## External dependencies

Manifest dependencies: `umbriel` and `sleep` (one reconnecting host-managed CLI event stream on API 52/53), `gtk-launch` (only explicit pinned desktop launches) and `niri` (only niri focus/close actions). Commands use argument arrays. Umbriel window actions use the host API; subscriptions prefer native API 54 and use `runStream` on API 52/53. No subprocess polling, daemon, database, or state file. The single host-owned shell/CLI stream reconnects after two seconds on disconnection; Noctalia cancels its process group on reload/disable.

Network calls: none. Filesystem writes: none. Host icon lookup reads icon/desktop-entry files through `appIconPath`. Window titles are displayed locally and never logged. No downloaded code executes at plugin runtime.

## Testing

- [ ] Tested on Niri
- [ ] Tested on Hyprland
- [ ] Tested on Sway
- [ ] Tested on another compositor: Umbriel live session pending
- **Noctalia version tested against:** no running shell; source/API reviewed at core commit `42581ce5d3599be9cf54e971607c2d3ae43525fe`
- **Plugin API level:** 52

45 Luau fixture tests pass, including 9,100 width combinations, five-window badge/cycling, twenty-app overflow, focus reveal, filters, aliases, pinned running windows, drag reorder, safe actions, setting changes and reset recovery. All four sources compile with `luau-compile`. Canonical community manifest validation passes at the exact community-pinned validator `99a892dc9cb3490634412701c45acd024fe0383b`, whose 178 tests also pass. A real-pipe shell integration test verifies snapshot framing, disconnect reset, reconnect, and process-group cleanup with a fake Umbriel CLI. Noctalia desktop acceptance remains pending.

## Screenshots / Videos

Offline fixture renders are committed in `smart-taskbar/screenshots/` and visibly identified. Real Noctalia collapsed, expanded, grouped, and overflow screenshots must replace these before production acceptance. The thumbnail was exported with the official thumbnail generator using the labeled offline overflow preview.

## Checklist
**Ready-for-review requirement:** Every box in this section must be checked. If any statement is not true, keep the
pull request as Draft. An explanation does not replace a required check.

Manifest descriptions and all README prose must be English; no translated sections or localized README copies.

- [x] The directory name matches the part of `id` after the `/` in `plugin.toml` exactly.
- [x] It ships `plugin.toml`, `README.md`, `thumbnail.webp`, and `translations/en.json`.
- [x] `README.md` follows the
      [README template](https://github.com/noctalia-dev/community-plugins/blob/main/README_TEMPLATE.md), documents
      every entry id and dependency, and includes exact panel IPC commands and launcher prefixes where applicable.
- [x] `thumbnail.webp` is present and relevant; for a new plugin I created it with the [thumbnail generator](https://assets.noctalia.dev/plugins/thumbnail-generator.html), and for an update I regenerated it with the generator if the visual identity or user-facing appearance changed.
- [x] `version` follows semver and is bumped in this PR; `plugin_api` is the oldest API level this plugin requires.
- [x] Every non-English translation in this PR uses a locale supported by Noctalia core, and I can read, write, and
      understand that language well enough to review and maintain it (no unreviewed machine/LLM translations).
- [x] I did not edit `catalog.toml`; CI generates it.
- [x] This PR touches exactly one plugin directory.

## Code review attestation

Plugins run as trusted, unsandboxed Luau in the user's session. Confirm:
**Ready-for-review requirement:** Every attestation below must be checked.

- [x] The code is readable and not obfuscated, minified, or generated.
- [x] Code identifiers and code comments are in English.
- [x] It does not download and execute remote code.
- [x] Every network call, filesystem write, and spawned process is something the description above accounts for.
- [x] I have the right to publish this code under the `license` declared in `plugin.toml`.

The compositor testing requirement remains unchecked; no unrun desktop test is represented as passed. No non-English translations are included.
