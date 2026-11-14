# Settings

Expand **Widget** in the normal editor. All plugin controls are available together, with related fields adjacent. No dropdown, conditional page visibility, or advanced toggle hides plugin controls. The Area column below describes their ordering; it does not claim native accordion sections. Noctalia’s public plugin API currently has no section/group field.

| Area | Setting | Default | Meaning |
| --- | --- | --- | --- |
| Behavior | `expand_mode` | `"hover"` | Hover to reveal running apps, click to toggle, or keep the dock expanded. |
| Behavior | `hover_delay` | `150` | Wait before opening the application strip on hover. |
| Behavior | `collapse_delay` | `400` | Wait after the pointer leaves. Manual sorting stays open until clicked to protect drags. |
| Behavior | `animations` | `true` | Smooth expansion fades and optional icon enlargement. Turn off for reduced motion. |
| Behavior | `animation_duration` | `120` | Duration of short fades and hover enlargement; no idle frame loop. |
| Applications | `display_mode` | `"running"` | Additional workspace and output filters below apply to running windows. |
| Applications | `grouping` | `"app"` | Unknown application IDs remain separate. Workspace groups use a representative application icon. |
| Applications | `workspace_filter` | `"all"` | Active uses compositor active or focused workspaces; combines with output filtering. |
| Applications | `output_filter` | `"all"` | Current means this bar instance’s output, not the globally focused monitor. |
| Applications | `show_minimized` | `true` | Umbriel and Mango report minimized state; unavailable state is treated as not minimized. |
| Applications | `sorting` | `"launch"` | Launch order means first observed order. Manual order is per instance and resets on reload. |
| Applications | `pinned_apps` | `[]` | Exact desktop-entry IDs for launchers. Launchers appear with matching open windows; the entire widget hides when no matching windows remain. |
| Applications | `exclusions` | `[]` | Exact normalized desktop/application IDs. No shell patterns. |
| Layout | `min_width` | `64` | Minimum expanded extent in logical pixels, limited by maximum width. |
| Layout | `max_width` | `420` | Main-axis limit, including padding and arrows. Use bar/widget scale 1 and host capsule padding 0 for the same outer limit. |
| Layout | `collapsed_width` | `64` | Fixed collapsed extent in logical pixels. Hidden completely when no matching windows are open. |
| Layout | `icon_size` | `22` | Base size in logical pixels. Leave room for hover enlargement within your bar thickness. |
| Layout | `icon_spacing` | `4` | Gap between application cells. Single-window apps have no count lane or marker. |
| Layout | `overflow_behavior` | `"items"` | Wheel navigation replaces visible items; the viewport is clipped. |
| Layout | `show_scroll_indicators` | `true` | Subtle direction indicators inside the width budget. |
| Appearance | `collapsed_label` | `"none"` | Optional text within the fixed width. Single-window apps never show a count; side bars show the icon only. |
| Appearance | `duplicate_indicator` | `"badge"` | Numeric corner badges appear only for applications with more than one window. |
| Appearance | `badge_placement` | `"after"` | Place duplicate-window count badges at the upper left or upper right of the icon. |
| Appearance | `hover_enlarge` | `false` | Magnify the hovered application inside a fixed cell. No bar movement; respects reduced motion. |
| Appearance | `hover_scale` | `1.15` | Maximum icon scale. Set bar thickness to at least icon size × scale + 8 logical pixels; 1.15 fits a 22 px icon in a 34 px bar. |
| Appearance | `capsule_radius` | `14` | Logical pixels for the plugin’s own theme-colored capsule. |
| Appearance | `opacity` | `0.9` | Background alpha only; icons and text stay opaque. |
| Appearance | `border` | `false` | Use the active theme outline role. |
| Appearance | `active_indicator` | `true` | Use the theme primary container role. |
| Appearance | `minimized_indicator` | `true` | Dim a group only when every member is minimized. |
| Appearance | `urgent_indicator` | `true` | Use the theme error role when compositor events provide urgency. Umbriel does not guarantee this field. |
| Interaction | `click_behavior` | `"cycle"` | Grouped apps always cycle windows. Minimize requires compositor support. |
| Interaction | `middle_click` | `"settings"` | Host defaults to widget settings. To use these actions, explicitly set this instance’s actions.middle = "none". |
| Interaction | `scroll_step` | `1` | Application items per wheel gesture in item mode. |
| Interaction | `auto_reveal_focused` | `true` | Reveal on focus changes and expansion. Manual wheel navigation remains usable until focus changes. |
| Advanced | `app_aliases` | `{}` | Map normalized unusual application IDs to desktop-entry IDs. Matching ignores case and a .desktop suffix. |
| Advanced | `refresh_fallback` | `60` | Retry interval if subscription startup fails. CLI streams reconnect after two seconds; socket bridges use 1–30 second backoff. |
| Advanced | `diagnostic_logging` | `false` | Log subscription and action errors. Window titles are not logged. |
| Advanced | `compositor_compatibility` | `"auto"` | Auto-detect Umbriel, niri, Hyprland, Mango or Sway. |
