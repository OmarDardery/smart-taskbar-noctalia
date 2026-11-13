# Settings

| Setting | Default | Meaning |
| --- | --- | --- |
| `expand_mode` | `"hover"` | Whole-widget native hover, click toggle, or always expanded. |
| `hover_delay` | `150` | Milliseconds before expanding. |
| `collapse_delay` | `400` | Milliseconds before collapsing. Manual sorting stays open until clicked to protect drags. |
| `animations` | `true` | Fade newly expanded content. Disable for reduced motion. |
| `animation_duration` | `120` | Milliseconds for the content fade. No continuous scroll animation is implied. |
| `min_width` | `64` | Minimum expanded extent, clamped to maximum width. |
| `max_width` | `420` | Maximum content extent in logical pixels; use capsule_padding = 0 and scale = 1 for a matching outer budget. |
| `collapsed_width` | `64` | Stable collapsed extent, clamped to maximum width. |
| `icon_size` | `22` | Logical pixels. Choose a size that fits your bar thickness. |
| `icon_spacing` | `4` | Logical pixels between application cells. |
| `overflow_behavior` | `"items"` | Wheel navigation replaces visible items; the viewport is clipped. |
| `scroll_step` | `1` | Application items per wheel gesture in item mode. |
| `auto_reveal_focused` | `true` | Reveal on focus changes and expansion. Manual wheel navigation remains usable until focus changes. |
| `show_scroll_indicators` | `true` | Subtle direction indicators inside the width budget. |
| `display_mode` | `"running"` | Additional workspace and output filters below apply to running windows. |
| `workspace_filter` | `"all"` | Active uses compositor active or focused workspaces; combines with output filtering. |
| `output_filter` | `"all"` | Current means this bar instance’s output, not the globally focused monitor. |
| `show_minimized` | `true` | Umbriel reports minimized state; unavailable state is treated as not minimized. |
| `grouping` | `"app"` | Unknown application IDs remain separate. Workspace groups use a representative application icon. |
| `duplicate_indicator` | `"badge"` | Every grouped window contributes to the count. Dots above three show an overflow mark. |
| `sorting` | `"launch"` | Launch order means first observed order. Manual order is per instance and resets on reload. |
| `exclusions` | `[]` | Exact normalized desktop/application IDs. No shell patterns. |
| `pinned_apps` | `[]` | Desktop-entry IDs, for example org.mozilla.firefox. gtk-launch is needed only to launch pins. |
| `app_aliases` | `{}` | Map normalized unusual application IDs to desktop-entry IDs. Matching ignores case and a .desktop suffix. |
| `collapsed_label` | `"none"` | Text is ellipsized within the stable width. Side bars show the icon only. |
| `placeholder` | `""` | Shown when there is no focused application. Bounded by collapsed width. |
| `placeholder_glyph` | `"apps"` | Theme glyph when no application is focused. |
| `capsule_radius` | `14` | Logical pixels for the plugin’s own theme-colored capsule. |
| `opacity` | `0.9` | Background alpha only; icons and text stay opaque. |
| `border` | `false` | Use the active theme outline role. |
| `active_indicator` | `true` | Use the theme primary container role. |
| `minimized_indicator` | `true` | Dim a group only when every member is minimized. |
| `urgent_indicator` | `true` | Use the theme error role when compositor events provide urgency. Umbriel does not guarantee this field. |
| `badge_placement` | `"after"` | A fixed count lane prevents layout shifts. Badges are inline, not absolute overlays. |
| `click_behavior` | `"cycle"` | Grouped apps always cycle windows. Minimize requires compositor support. |
| `middle_click` | `"settings"` | Host defaults to widget settings. To use these actions, explicitly set this instance’s actions.middle = "none". |
| `refresh_fallback` | `60` | Seconds between idle subscription retries if a supported compositor could not subscribe. No subprocess polling. |
| `diagnostic_logging` | `false` | Log subscription and action errors. Window titles are not logged. |
| `compositor_compatibility` | `"auto"` | Unsupported compositors show a placeholder. Umbriel supports API 52+. niri requires API 54 for native events. |
