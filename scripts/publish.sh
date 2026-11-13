#!/usr/bin/env bash
# Run only after gh is authenticated with repository/fork/issue creation rights.
# Publishes the already prepared source and a draft community submission.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
login="$(gh api user --jq .login)"
if [[ "$login" != OmarDardery ]]; then
  echo 'This source declares OmarDardery as its publisher. Update the canonical ID and publication metadata before using another account.' >&2
  exit 1
fi
if ! gh repo view OmarDardery/smart-taskbar-noctalia >/dev/null 2>&1; then
  gh repo create OmarDardery/smart-taskbar-noctalia --public --source "$root" --remote origin --push
else
  if ! git remote get-url origin >/dev/null 2>&1; then
    git remote add origin https://github.com/OmarDardery/smart-taskbar-noctalia.git
  fi
  remote_url="$(git remote get-url origin)"
  if [[ "$remote_url" != https://github.com/OmarDardery/smart-taskbar-noctalia.git && "$remote_url" != git@github.com:OmarDardery/smart-taskbar-noctalia.git ]]; then
    echo 'Unexpected origin URL; inspect the repository before publishing.' >&2
    exit 1
  fi
  git push -u origin main
fi
git push origin v0.1.1
if ! gh repo view OmarDardery/community-plugins >/dev/null 2>&1; then
  gh repo fork noctalia-dev/community-plugins --clone=false
fi
submission_dir="$(mktemp -d)"
echo "Preparing community submission in $submission_dir"
git clone https://github.com/OmarDardery/community-plugins.git "$submission_dir/community"
git -C "$submission_dir/community" remote add upstream https://github.com/noctalia-dev/community-plugins.git
git -C "$submission_dir/community" fetch upstream main
git -C "$submission_dir/community" checkout -b add-smart-taskbar upstream/main
if [[ -e "$submission_dir/community/smart-taskbar" ]]; then
  echo 'The community name is already taken. Inspect it before proceeding.' >&2
  exit 1
fi
cp -R "$root/smart-taskbar" "$submission_dir/community/smart-taskbar"
git -C "$submission_dir/community" add smart-taskbar
git -C "$submission_dir/community" commit -m 'Add Smart Taskbar application switcher'
git -C "$submission_dir/community" push -u origin add-smart-taskbar
gh pr create --repo noctalia-dev/community-plugins --base main --head OmarDardery:add-smart-taskbar --draft --title 'Add Smart Taskbar application switcher (API 52 preview)' --body-file "$root/docs/community-pr.md"
gh issue create --repo noctalia-dev/noctalia --title '[FEATURE] Public continuous scroll viewport for declarative bar widgets' --body-file "$root/docs/upstream-scroll-request.md"
