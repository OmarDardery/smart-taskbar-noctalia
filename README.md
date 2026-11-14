# Smart Taskbar

A Noctalia **API 52+** application switcher, distributed as one bar widget. Source and installation documentation are in [smart-taskbar/README.md](smart-taskbar/README.md).

Version 1.0.0 is a release candidate. The Luau fixture tests and official community manifest validation run locally; live Noctalia desktop validation is pending. Umbriel now works with API 52/53 through its public CLI stream. API 54+ uses native subscriptions. Match the host’s reported API range; version labels alone are insufficient.

- [Settings reference](docs/settings.md)
- [Validation and desktop test matrix](docs/TESTING.md)
- [Public API decisions](docs/API.md)
- [Publishing status](docs/PUBLISHING.md)

Run executable tests with Python 3.11+ and the official Luau CLI:

```sh
LUAU=/path/to/luau python3 tests/run.py
```

The tests execute the shipped Luau source with a deterministic host fixture. They do not start Noctalia or a compositor. Optional labeled offline previews can be regenerated with `python3 tests/preview.py` after installing Pillow in your development environment.

Umbriel/niri need no Python. Hyprland, Mango and Sway use one host-owned Python standard-library helper for public local socket IPC. There is no network access, external daemon or state file. On API 52/53 with Umbriel it starts one host-managed shell/CLI event stream. See the plugin README for conditional CLI requirements.

## Install

Requires a Noctalia build supporting **plugin API 52 or newer**:

```sh
noctalia msg plugins source add smart-taskbar git https://github.com/OmarDardery/smart-taskbar-noctalia
noctalia msg plugins enable omardardery/smart-taskbar
```

Add `omardardery/smart-taskbar:taskbar` in Bar settings. Native enabling and desktop behavior still require live acceptance testing. See the plugin README for width-budget setup and compatibility details.

Community submission: [draft PR #1434](https://github.com/noctalia-dev/community-plugins/pull/1434). Automated checks pass; live desktop acceptance remains pending.

Update an existing source with `noctalia msg plugins update smart-taskbar`, then enable the plugin again. Version 1.0.0 declares API 52.

Smart Taskbar hides when no matching windows remain, shows numeric badges only for duplicates, and offers optional fixed-cell hover enlargement.

All plugin settings are visible together without a page dropdown. Expand Widget to see all plugin controls together; related settings remain adjacent. Separate plugin accordion sections require a public Noctalia API enhancement.

[Compositor compatibility and protocol references](docs/COMPATIBILITY.md). Automated checks cover all five adapters; real desktop acceptance remains pending.
