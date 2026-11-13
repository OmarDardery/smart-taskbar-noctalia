# Smart Taskbar

A Noctalia **API 54** application switcher, distributed as one bar widget. Source and installation documentation are in [smart-taskbar/README.md](smart-taskbar/README.md).

Version 0.1.0 is a preview release. The Luau fixture tests and official community manifest validation run locally; live Noctalia desktop validation is pending. API 54 is marked **unreleased** in the official documentation checked on November 13, 2026. Stable v5.4.1 does not provide every API used here.

- [Settings reference](docs/settings.md)
- [Validation and desktop test matrix](docs/TESTING.md)
- [Public API decisions](docs/API.md)
- [Publishing status](docs/PUBLISHING.md)

Run executable tests with Python 3.11+ and the official Luau CLI:

```sh
LUAU=/path/to/luau python3 tests/run.py
```

The tests execute the shipped Luau source with a deterministic host fixture. They do not start Noctalia or a compositor. Optional labeled offline previews can be regenerated with `python3 tests/preview.py` after installing Pillow in your development environment.

The plugin itself needs no Python, browser, daemon, network access, or state files. See the plugin README for conditional CLI requirements.
