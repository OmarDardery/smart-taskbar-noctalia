# Distribution and publication status

Version **0.1.0 preview**, canonical plugin ID `omardardery/smart-taskbar`, entry `taskbar`, minimum API **54**.

The publisher created the public source repository [OmarDardery/smart-taskbar-noctalia](https://github.com/OmarDardery/smart-taskbar-noctalia) and [community fork](https://github.com/OmarDardery/community-plugins). The repository name differs from the canonical plugin ID; the plugin directory remains `smart-taskbar/`, as required by Noctalia.

## Install from the custom Git source

```sh
noctalia msg plugins source add smart-taskbar git https://github.com/OmarDardery/smart-taskbar-noctalia
noctalia msg plugins enable omardardery/smart-taskbar
```

Add `omardardery/smart-taskbar:taskbar` in Bar settings. Set host capsule off, capsule padding 0, bar and widget scale 1, and no custom label/group wrapper padding for a matching outer width budget.

Source layout, catalog, manifest, source compilation and executable fixture tests have been validated. Real enabling/bar placement and the [desktop acceptance matrix](TESTING.md) require a Noctalia API 54 session and remain pending. Keep community submission draft until live testing and actual screenshots are complete. The committed previews are explicitly labeled offline fixtures.

## Submission

The prepared community PR body is [community-pr.md](community-pr.md). Submit only `smart-taskbar/`; do not copy the custom source root catalog into the community repository. The focused scrolling enhancement request is [upstream-scroll-request.md](upstream-scroll-request.md). Upstream issue creation previously returned HTTP 403; publication to user-owned repositories does not establish permission to create upstream issues or PRs.

`scripts/publish.sh` contains the publication commands. It must only be used with an appropriately authorized GitHub login; it never marks the community PR ready or claims live desktop testing passed.

## Published source and submission branch

The complete source is pushed to [smart-taskbar-noctalia](https://github.com/OmarDardery/smart-taskbar-noctalia). An independent fresh clone passed all 24 Luau fixture tests and package checks. The community branch is pushed to [OmarDardery/community-plugins: add-smart-taskbar](https://github.com/OmarDardery/community-plugins/tree/add-smart-taskbar); it changes exactly the plugin directory and does not edit the community catalog.

The publisher opened [community draft PR #1434](https://github.com/noctalia-dev/community-plugins/pull/1434). Its `enforce`, `notify-plugin-authors`, and `validate` checks passed. The latest source-repository branch and tag CI runs also passed canonical validation, compilation, and all 24 Luau fixture tests. No review comments were present when checked.

The PR description currently contains the unfilled GitHub template. Attempting to update it through the integration returned HTTP 403. The publisher must replace it manually with [the prepared description](community-pr.md), leaving live-compositor testing unchecked and keeping the PR draft. Source edits can still be pushed through the fork branch without recreating the PR.

Upstream issue creation remains blocked; the focused scrolling request is prepared in [upstream-scroll-request.md](upstream-scroll-request.md). Live desktop acceptance and real screenshots remain pending.
