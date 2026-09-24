#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${CN_TAG:?}" "${GITHUB_SHA:?}" "${GH_REPO:?}"
sha256sum --check RecipeLab.apk.sha256

# Never move an existing release tag or replace a published release.
if git show-ref --verify --quiet "refs/tags/$CN_TAG"; then
  [[ "$(git rev-parse "$CN_TAG^{commit}")" == "$GITHUB_SHA" ]] || {
    echo 'Existing tag points at a different commit'; exit 1;
  }
fi
gh api --paginate "repos/$GH_REPO/releases" --jq '.[].tag_name' > out/release-tags.txt
if grep -Fxq "$CN_TAG" out/release-tags.txt; then
  [[ "$(gh release view "$CN_TAG" --json isDraft --jq .isDraft)" == true ]] || {
    echo 'Release is already published; use a new batch tag'; exit 1;
  }
else
  gh release create "$CN_TAG" --draft --target "$GITHUB_SHA" --title "Recipe Lab CN · $CN_TAG" --notes 'Build in progress'
fi
{
  cat docs/CN_RELEASE_NOTES.md
  printf '\n\n源码提交：`%s`\n\n构建记录：https://github.com/%s/actions/runs/%s\n\n' "$GITHUB_SHA" "$GH_REPO" "$GITHUB_RUN_ID"
  printf 'SHA-256：`%s`\n' "$(cut -d ' ' -f1 RecipeLab.apk.sha256)"
} > out/cn-release-notes.md
gh release edit "$CN_TAG" --target "$GITHUB_SHA" --title "Recipe Lab CN · $CN_TAG" --notes-file out/cn-release-notes.md
gh release upload "$CN_TAG" RecipeLab.apk RecipeLab.apk.sha256 --clobber
mkdir -p out/release-download
gh release download "$CN_TAG" --pattern 'RecipeLab.apk*' --dir out/release-download --clobber
cmp RecipeLab.apk out/release-download/RecipeLab.apk
cmp RecipeLab.apk.sha256 out/release-download/RecipeLab.apk.sha256
gh release edit "$CN_TAG" --draft=false --latest
