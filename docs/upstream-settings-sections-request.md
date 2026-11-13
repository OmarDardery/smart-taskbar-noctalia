# [FEATURE] Public native sections for manifest-declared plugin settings

Plugin widget settings all appear in the host editor's generic Widget accordion. A plugin with behavior, application filtering, layout, appearance, interaction, and diagnostic controls cannot place them in individual native sections.

The current public manifest schema exposes label_key, description_key, typed defaults, ranges, visible_when, and advanced, but no group or section field. Core ManifestField has no such member, and manifestSettingSpecs leaves WidgetSettingPresentation.group at its default "widget". Built-in widgets use native groups, but plugins cannot declare them through the public API.

A dropdown plus visible_when can simulate pages, but hides controls and makes them hard to find. Smart Taskbar initially tried this; desktop feedback led to removing it so every control is visible at once. Fake setting fields used as headings would introduce misleading controls and should not be necessary.

Requested public capability:

- A manifest-declared section ID and translated heading for related fields.
- Native accordion rendering in the main widget settings dialog, using the same editor controls and persistence as ordinary plugin fields.
- Stable declaration order, translated headings, and optional collapse defaults.
- Scoped section IDs so plugins do not collide with host groups.
- The same metadata usable for plugin-level and panel settings where applicable.
- An explicit plugin API compatibility level and matching canonical validator support.

All field values should continue to use the host's normal config/settings machinery. This request does not need a new custom settings surface or a plugin settings-write API.

Until this is supported, Smart Taskbar exposes all controls together in declaration order under Widget and makes no claim that logical documentation areas are native sections.
