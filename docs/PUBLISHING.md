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

Creating the upstream PR still returned `Resource not accessible by integration` through both GraphQL and REST (HTTP 403). Upstream issue creation also remains forbidden. These permissions are separate from writing to the two user-owned repositories. No upstream PR or issue has been created.

To finish submission manually, open [the community comparison](https://github.com/noctalia-dev/community-plugins/compare/main...OmarDardery:add-smart-taskbar?expand=1), use the title **Add Smart Taskbar application switcher (API 54 preview)**, paste [the prepared PR body](community-pr.md), and choose **Create draft pull request**. Leave live-compositor test boxes unchecked. The public source and custom Git installation do not depend on community acceptance.
