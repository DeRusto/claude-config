#!/usr/bin/env bash
# Adds templates/claude.yml to every repo owned by derusto (skips forks, archived
# repos, this repo, and repos that already have the file). Commits straight to
# each repo's default branch.
#
#   ./scripts/rollout.sh                 # dry run: lists what it would do
#   APPLY=1 ./scripts/rollout.sh         # actually commit the file
#   APPLY=1 CLAUDE_CODE_OAUTH_TOKEN=... ./scripts/rollout.sh   # also set the secret
set -euo pipefail

OWNER=derusto
TEMPLATE="$(dirname "$0")/../templates/claude.yml"
WF_PATH=.github/workflows/claude.yml
CONTENT=$(base64 -w0 < "$TEMPLATE" 2>/dev/null || base64 < "$TEMPLATE" | tr -d '\n')

gh repo list "$OWNER" --limit 1000 --source --no-archived --json name --jq '.[].name' |
while read -r name; do
  repo="$OWNER/$name"
  [ "$name" = "claude-config" ] && continue

  if gh api "repos/$repo/contents/$WF_PATH" >/dev/null 2>&1; then
    echo "skip   $repo (workflow already exists)"
    continue
  fi

  if [ -z "${APPLY:-}" ]; then
    echo "would  $repo"
    continue
  fi

  gh api -X PUT "repos/$repo/contents/$WF_PATH" \
    -f message="Add Claude workflow" -f content="$CONTENT" >/dev/null
  echo "added  $repo"

  if [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
    printf '%s' "$CLAUDE_CODE_OAUTH_TOKEN" | gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo "$repo"
  fi
done
