# Distribution and publication status

Version **2.0.0 release candidate**, canonical plugin ID `omardardery/smart-taskbar`, entry `taskbar`, minimum API **52**.

The publisher created the public source repository [OmarDardery/smart-taskbar-noctalia](https://github.com/OmarDardery/smart-taskbar-noctalia) and [community fork](https://github.com/OmarDardery/community-plugins). The repository name differs from the canonical plugin ID; the plugin directory remains `smart-taskbar/`, as required by Noctalia.

## Install from the custom Git source

```sh
noctalia msg plugins source add smart-taskbar git https://github.com/OmarDardery/smart-taskbar-noctalia
noctalia msg plugins enable omardardery/smart-taskbar
```

Add `omardardery/smart-taskbar:taskbar` in Bar settings. Set host capsule off, capsule padding 0, bar and widget scale 1, and no custom label/group wrapper padding for a matching outer width budget.

Source layout, catalog, manifest, source compilation and executable fixture tests have been validated. Real enabling/bar placement and the [desktop acceptance matrix](TESTING.md) require a Noctalia API 52+ Umbriel session and remain pending. Keep community submission draft until live testing and actual screenshots are complete. The committed previews are explicitly labeled offline fixtures.

## Submission

The prepared community PR body is [community-pr.md](community-pr.md). Submit only `smart-taskbar/`; do not copy the custom source root catalog into the community repository. The focused scrolling enhancement request is [upstream-scroll-request.md](upstream-scroll-request.md). Upstream issue creation previously returned HTTP 403; publication to user-owned repositories does not establish permission to create upstream issues or PRs.

`scripts/publish.sh` contains the publication commands. It must only be used with an appropriately authorized GitHub login; it never marks the community PR ready or claims live desktop testing passed.

## Published source and submission branch

The complete source is pushed to [smart-taskbar-noctalia](https://github.com/OmarDardery/smart-taskbar-noctalia). An independent fresh clone passed all 24 Luau fixture tests and package checks. The community branch is pushed to [OmarDardery/community-plugins: add-smart-taskbar](https://github.com/OmarDardery/community-plugins/tree/add-smart-taskbar); it changes exactly the plugin directory and does not edit the community catalog.

The publisher opened [community draft PR #1434](https://github.com/noctalia-dev/community-plugins/pull/1434). Its `enforce`, `notify-plugin-authors`, and `validate` checks passed. The latest source-repository branch and tag CI runs also passed canonical validation, compilation, and all 24 Luau fixture tests. No review comments were present when checked.

The PR description currently contains the unfilled GitHub template. Attempting to update it through the integration returned HTTP 403. The publisher must replace it manually with [the prepared description](community-pr.md), leaving live-compositor testing unchecked and keeping the PR draft. Source edits can still be pushed through the fork branch without recreating the PR.

Upstream issue creation remains blocked; the focused scrolling request is prepared in [upstream-scroll-request.md](upstream-scroll-request.md). Live desktop acceptance and real screenshots remain pending.

The PR description was filled in, but upstream enforcement flagged three shortened checklist items. The prepared body now preserves the exact upstream checklist wording and passes the upstream draft-description checker locally. The publisher must paste the corrected body because the integration cannot edit upstream PR metadata.

## Version 0.1.1 compatibility update

The user’s desktop reports API range 3–53. Version 0.1.1 lowers the minimum to API 52 by adding a public Umbriel CLI event transport; API 54 native subscriptions remain optional. The code has 34 passing Luau fixture tests and one passing real-pipe/process-group test with a fake CLI. Actual desktop execution remains pending. Both the custom source and existing community PR branch carry the update; no new PR is required.

The upstream PR title/body may still mention API 54 until edited manually. Use the updated prepared body in `docs/community-pr.md` and title **Add Smart Taskbar application switcher (API 52 preview)** when updating its metadata. Keep it draft.

Version 0.1.2 adds hide-on-empty, numeric-only duplicate badges without placeholder lanes, native conditional settings pages, and optional bounded icon magnification. The user requested making PR #1434 ready for review after pushing. The transition is attempted without converting unrun desktop checks into passed tests; the upstream ready-state bot requires a checked compositor test.

### 0.1.2 publication result

Version [0.1.2](https://github.com/OmarDardery/smart-taskbar-noctalia/releases/tag/v0.1.2) and the updated PR branch are published. Source [CI run 43502864159](https://github.com/OmarDardery/smart-taskbar-noctalia/actions/runs/43502864159) passed compilation, all 45 Luau tests, the shell-stream test, package checks, and canonical validation. Community [validation run 43502880213](https://github.com/noctalia-dev/community-plugins/actions/runs/43502880213) passed. An independent checkout also passed package checks.

Updating PR #1434's title/body and marking it ready were both attempted after validation. GitHub rejected the metadata update with HTTP 403 and the ready mutation with `FORBIDDEN: Resource not accessible by integration`. The PR remains draft. This is an upstream GitHub integration permission restriction, not an automatic approval-review rejection. Its ready-state checker also requires at least one recorded compositor test; no missing desktop result was checked as passed. The updated prepared body remains in `docs/community-pr.md` for the publisher to apply manually.

Version 0.1.3 removes the settings selector and makes all plugin controls visible together in the host Widget section. Separate native sections cannot be declared by the current plugin manifest API; the missing group/section capability is documented in `upstream-settings-sections-request.md`.

The v0.1.3 native-settings-sections feature request was prepared and issue creation attempted. GitHub rejected it with HTTP 403 (`Resource not accessible by integration`), so it remains a local/public documentation draft, not a filed upstream issue.

Version 1.0.0 adds public-protocol Hyprland, Mango and Sway adapters, API 52/53 niri events, event deduplication, coalesced snapshots and stable multi-tag/workspace grouping. Automated protocol coverage does not replace live desktop acceptance. The GitHub release is marked prerelease until that acceptance is recorded.

Version 2.0.0 polishes count badges and adds inline capsule placement with width-aware overflow. Only Umbriel has author-reported desktop testing; these new visual changes still require a desktop recheck. Other compositor adapters have automated fixtures only.
