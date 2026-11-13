# Smart Taskbar

A Noctalia **API 52+** application switcher, distributed as one bar widget. Source and installation documentation are in [smart-taskbar/README.md](smart-taskbar/README.md).

Version 0.1.1 is a preview release. The Luau fixture tests and official community manifest validation run locally; live Noctalia desktop validation is pending. Umbriel now works with API 52/53 through its public CLI stream. API 54+ uses native subscriptions. Match the host’s reported API range; version labels alone are insufficient.

- [Settings reference](docs/settings.md)
- [Validation and desktop test matrix](docs/TESTING.md)
- [Public API decisions](docs/API.md)
- [Publishing status](docs/PUBLISHING.md)

Run executable tests with Python 3.11+ and the official Luau CLI:

```sh
LUAU=/path/to/luau python3 tests/run.py
```

The tests execute the shipped Luau source with a deterministic host fixture. They do not start Noctalia or a compositor. Optional labeled offline previews can be regenerated with `python3 tests/preview.py` after installing Pillow in your development environment.

The plugin itself needs no Python, browser, daemon, network access, or state files. On API 52/53 with Umbriel it starts one host-managed shell/CLI event stream. See the plugin README for conditional CLI requirements.

## Install the published preview

Requires a Noctalia build supporting **plugin API 52 or newer**:

```sh
noctalia msg plugins source add smart-taskbar git https://github.com/OmarDardery/smart-taskbar-noctalia
noctalia msg plugins enable omardardery/smart-taskbar
```

Add `omardardery/smart-taskbar:taskbar` in Bar settings. Native enabling and desktop behavior still require live acceptance testing. See the plugin README for width-budget setup and compatibility details.

Community submission: [draft PR #1434](https://github.com/noctalia-dev/community-plugins/pull/1434). Automated checks pass; live desktop acceptance remains pending.

Update an existing source with `noctalia msg plugins update smart-taskbar`, then enable the plugin again. Version 0.1.1 declares API 52.
