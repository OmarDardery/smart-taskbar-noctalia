# Distribution and publication status

Version: **0.1.0 preview**, plugin ID `omardardery/smart-taskbar`, entry `taskbar`, minimum plugin API **54**.

## Completed locally

- Git source layout with a root `catalog.toml` and one `smart-taskbar/` plugin directory.
- Static manifest, Luau entry/modules, English settings, MIT license, detailed README, and four labeled offline fixture previews.
- `thumbnail.webp` exported through the official thumbnail generator in Chromium, using the labeled offline overflow preview. The generator itself was not modified.
- Luau executable fixture tests, source compilation, package checks, and exact pinned official community validation.
- Local Git version history, tagged source, GitHub Actions checks, community PR body, and focused upstream issue body.

## Blocked remote actions

GitHub identity lookup succeeded as `OmarDardery`, but each requested publishing mutation was rejected by GitHub:

| Attempt | Actual result |
| --- | --- |
| Create public `OmarDardery/smart-taskbar` repository | GraphQL `Resource not accessible by integration (createRepository)` |
| Fork `noctalia-dev/community-plugins` for submission | HTTP 403 `Resource not accessible by integration` |
| Create upstream scrolling feature issue in `noctalia-dev/noctalia` | HTTP 403 `Resource not accessible by integration` |

These are remote GitHub permission errors, not user-denied or automatic-review-rejected commands. No repository, fork, PR, release, or upstream issue was created. Consequently there are no final repository/PR/issue links and no maintainer feedback to address. The intended custom-source URL in installation documentation becomes usable only after publication.

## Install locally for desktop acceptance

On a machine running Noctalia API 54, unpack this source and use its absolute directory:

```sh
noctalia msg plugins source add smart-taskbar-dev path /absolute/path/to/smart-taskbar
noctalia msg plugins enable omardardery/smart-taskbar
```

Add `omardardery/smart-taskbar:taskbar` in the Bar settings. For a fixed outer budget use host capsule off, capsule padding 0, bar and widget scale 1, no custom label, and no capsule-group wrapper padding. The plugin README contains the named-instance configuration and settings reference.

These commands and source layout match official documentation. They have not been executed in a running Noctalia session here. Complete [the desktop matrix](TESTING.md) before representing this as production-ready.

## Remaining publication steps

Use a GitHub login with permission to create repositories, fork the community repository, and open PRs/issues. Do not paste credentials into source or chat. The prepared `scripts/publish.sh` performs the repository push, community fork/branch and **draft** submission, and upstream issue creation. It can be run after configuring an appropriately authorized `gh` login. It deliberately does not mark the community PR ready or invent live-test evidence.

Or perform the steps manually:

```sh
cd /absolute/path/to/smart-taskbar
gh repo create OmarDardery/smart-taskbar --public --source . --remote origin --push
git push origin v0.1.0

gh repo fork noctalia-dev/community-plugins --clone=false
git clone https://github.com/OmarDardery/community-plugins ../smart-taskbar-community
cd ../smart-taskbar-community
git remote add upstream https://github.com/noctalia-dev/community-plugins
git fetch upstream main
git checkout -b add-smart-taskbar upstream/main
cp -R ../smart-taskbar/smart-taskbar ./smart-taskbar
git add smart-taskbar
git commit -m 'Add Smart Taskbar application switcher'
git push -u origin add-smart-taskbar
gh pr create --repo noctalia-dev/community-plugins --base main --head OmarDardery:add-smart-taskbar --draft --title 'Add Smart Taskbar application switcher (API 54 preview)' --body-file ../smart-taskbar/docs/community-pr.md

gh issue create --repo noctalia-dev/noctalia --title '[FEATURE] Public continuous scroll viewport for declarative bar widgets' --body-file ../smart-taskbar/docs/upstream-scroll-request.md
```

Use only the plugin directory in the community PR; **do not add its root catalog**. The custom source's root catalog is separately maintained. After the public repo exists, independently clone it into an empty directory, run canonical validation, and verify installation, enabling and bar placement in a real session. Update the public installation URL if publishing under another owner; change the canonical plugin ID/author consistently before doing so.

Replace offline previews with real screenshots, record desktop results, then mark the PR ready only when its contribution checklist is true. Address CI and maintainer comments as they arrive. Publish an updated plugin version for functional changes.
