<!-- noctalia-pr-template:v1 -->

## Plugin

- **Id:** `omardardery/smart-taskbar`
- [x] New plugin
- [ ] Update to an existing plugin (version bumped in `plugin.toml`)

## What it does

Smart Taskbar is one API 54 Luau bar widget with stable collapsed extent, grouped numeric counts, native whole-widget hover expansion, click/always modes, and a bounded 420-logical-pixel default expanded extent. Overflow uses a clipped virtualized icon strip with wheel navigation and focus reveal. Umbriel is the primary adapter; niri receives events natively and uses its CLI on explicit focus/close actions.

Manual drag ordering stays within the widget and is in-memory. In manual mode expansion stays open until explicitly clicked because the public API lacks drag-start/end callbacks. Right click opens settings because native context menus are panel-only. Pin lists are settings-driven because configuration is read-only. Stable v5.4.1 is not supported: API 54 is documented as unreleased.

**Keep this PR draft.** The cloud environment has no Noctalia/compositor executable/session. Native installation, compositor actions, screenshots, device gestures, scaling and resource measurements are pending. The visual assets are clearly labeled offline fixture previews, not live screenshots.

## External dependencies

Manifest dependencies: `gtk-launch` (only explicit pinned desktop launches) and `niri` (only niri focus/close actions). Commands use argument arrays. Umbriel actions and all event subscriptions use the host API. No subprocess polling, daemon, database, or state file.

Network calls: none. Filesystem writes: none. Host icon lookup reads icon/desktop-entry files through `appIconPath`. Window titles are displayed locally and never logged. No downloaded code executes at plugin runtime.

## Testing

- [ ] Tested on Niri
- [ ] Tested on Hyprland
- [ ] Tested on Sway
- [ ] Tested on another compositor: Umbriel live session pending
- **Noctalia version tested against:** no running shell; source/API reviewed at core commit `42581ce5d3599be9cf54e971607c2d3ae43525fe`
- **Plugin API level:** 54

24 Luau fixture tests pass, including 2,275 width combinations, five-window badge/cycling, twenty-app overflow, focus reveal, filters, aliases, pinned running windows, drag reorder, safe actions, setting changes and reset recovery. All three sources compile with `luau-compile`. Canonical community manifest validation passes at the exact community-pinned validator `99a892dc9cb3490634412701c45acd024fe0383b`, whose 178 tests also pass. These tests do not establish desktop acceptance.

## Screenshots / Videos

Offline fixture renders are committed in `smart-taskbar/screenshots/` and visibly identified. Real Noctalia collapsed, expanded, grouped, and overflow screenshots must replace these before production acceptance. The thumbnail was exported with the official thumbnail generator using the labeled offline overflow preview.

## Checklist

- [x] The directory name matches the part of `id` after the `/` in `plugin.toml` exactly.
- [x] It ships `plugin.toml`, `README.md`, `thumbnail.webp`, and `translations/en.json`.
- [x] `README.md` follows the README template, documents every entry id and dependency, and includes exact panel IPC commands and launcher prefixes where applicable.
- [x] `thumbnail.webp` is present and relevant; for a new plugin I created it with the thumbnail generator.
- [x] `version` follows semver and is bumped in this PR; `plugin_api` is the oldest API level this plugin requires.
- [x] Every non-English translation in this PR uses a supported locale and is reviewed; no non-English translations are included.
- [x] I did not edit `catalog.toml`; CI generates it. Only the plugin directory is submitted here; the separate custom source's catalog is excluded.
- [x] This PR touches exactly one plugin directory.

## Code review attestation

- [x] The code is readable and not obfuscated, minified, or generated.
- [x] Code identifiers and code comments are in English.
- [x] It does not download and execute remote code.
- [x] Every network call, filesystem write, and spawned process is something the description above accounts for.
- [x] I have the right to publish this code under the `license` declared in `plugin.toml`.

The compositor testing requirement remains unchecked, so this submission must remain draft.
