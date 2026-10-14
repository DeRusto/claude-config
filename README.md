# claude-config

Shared Claude GitHub Actions setup for derusto's repos.

- `.github/workflows/claude.yml` — reusable workflow; runs Claude on `@claude` mentions with the ponytail skill always on.
- `plugins/ponytail` — the ponytail skill, served as a plugin from this repo's marketplace (`.claude-plugin/marketplace.json`).
- `templates/claude.yml` — the small caller file each repo needs.
- `scripts/rollout.sh` — adds the caller file (and optionally the API key secret) to all repos.

Change the prompt, skill or settings here and every repo picks it up on the next run.
