# Smart Taskbar 2.0

A compact Noctalia API 52+ application switcher with automatic bar sizing, grouped window counts, optional hover enlargement and bounded overflow navigation.

**Only Umbriel has author-reported desktop testing.** niri, Hyprland, Mango and Sway have automated fixture/protocol coverage only. Version 2.0.0 is a release candidate; its new sizing behavior needs a desktop recheck.

## Install or update

```sh
noctalia msg plugins source add smart-taskbar git https://github.com/OmarDardery/smart-taskbar-noctalia
noctalia msg plugins enable omardardery/smart-taskbar
```

For an existing installation:

```sh
noctalia msg plugins update smart-taskbar
noctalia msg plugins enable omardardery/smart-taskbar
```

Add **Smart Taskbar / taskbar** in Bar settings. The type is `omardardery/smart-taskbar:taskbar`.

## Sizing

In **Widget → Sizing**, choose **Auto** or **Manual**. Auto is the default. It reads public bar configuration when settings change, fits icons and hover enlargement to the available thickness, and adjusts spacing, radius and collapsed size. It compensates for bar/widget content and text scaling; output DPI is already handled by the host.

Auto hides **Minimum width, Collapsed width, Icon size, Icon spacing, and Capsule radius**. Manual shows them again and restores saved values. **Maximum width** remains available in both modes. The optional **Sizing bar name** appears only in Auto mode.

There is no public measured-thickness or placement-ID API. Auto conservatively fits matching configured placements on this output and orientation. Use Sizing bar name to restrict it to a specific bar. Missing placements fall back to saved manual dimensions. Capsule groups and custom wrappers can add outer extent beyond the plugin's budget; see the full README.

## Documentation

- [Plugin usage, settings and conditional dependencies](smart-taskbar/README.md)
- [Settings reference](docs/settings.md)
- [Compositor compatibility](docs/COMPATIBILITY.md)
- [Executed tests and pending desktop checks](docs/TESTING.md)
- [Public API decisions](docs/API.md)
- [Community PR #1434](https://github.com/noctalia-dev/community-plugins/pull/1434)

Run `LUAU=/path/to/luau python3 tests/run.py`, `python3 tests/stream_test.py`, `python3 tests/bridge_test.py`, and `python3 scripts/check.py` for reproducible checks. Preview images are visibly labeled offline fixtures, not desktop screenshots.
