# ccode-personal-plugins — AI Development Guide

## What is this

Personal fork of the [official Anthropic Claude Code plugin marketplace](https://github.com/anthropics/claude-plugins-official).
Syncs weekly with Anthropic upstream, adds our own plugins, and filters out unwanted ones.

## How syncing works

```
Anthropic upstream (claude-plugins-official)
       │
       │  .github/scripts/sync-upstream.sh (weekly cron or manual)
       ▼
marketplace.json
       │
       ├── applies metadata overrides from custom-plugins.json
       ├── appends our custom plugin entries
       └── removes plugins listed in exclude-plugins.txt
```

## Configuration files

| File | Purpose |
|------|---------|
| `.github/scripts/custom-plugins.json` | Our metadata + custom plugin entries |
| `.github/scripts/exclude-plugins.txt` | Upstream plugins to exclude (one per line) |
| `.github/scripts/sync-upstream.sh` | Sync script (fetches upstream, merges via jq) |
| `.claude-plugin/marketplace.json` | Generated result — the actual marketplace catalog |

## Directory structure

| Directory | What's inside |
|-----------|--------------|
| `plugins/` | Plugins bundled by Anthropic upstream (code-review, commit-commands, LSP servers, etc.) |
| `external_plugins/` | Partner plugins bundled by Anthropic upstream (supabase, playwright, gitlab, etc.) |

Both directories are synced from upstream — do not manually add files here.

## Custom plugins

Our own plugins are registered in `custom-plugins.json` and point to external repos:

| Plugin | Repo | Purpose |
|--------|------|---------|
| `claude-audit` | [mrkhachaturov/claude-audit-plugin](https://github.com/mrkhachaturov/claude-audit-plugin) | AI-readiness audit for Claude Code projects |

### rkstack integration (planned)

[rkstack](https://github.com/mrkhachaturov/rkstack) is our unified AI development
workflow — curated skill packs combining the best of superpowers, gstack, and other
upstream sources. It lives in a separate repo and will be registered here as multiple
plugins using the `git-subdir` source type (same pattern as AWS `agent-plugins.git`).

Once rkstack packs are ready, add entries to `custom-plugins.json`:

```json
{
  "name": "rkstack-{pack}",
  "description": "rkstack {pack} workflow skills",
  "category": "development",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/mrkhachaturov/rkstack.git",
    "path": "plugins/rkstack-{pack}",
    "ref": "main"
  },
  "homepage": "https://github.com/mrkhachaturov/rkstack"
}
```

Install per-project: `/plugin install rkstack-{pack}@ccode-personal-plugins`

This means one rkstack repo can deliver multiple independent skill packs,
each installable separately per-project — not system-wide.

## Related repositories

| Repo | Purpose |
|------|---------|
| [ccode-personal-plugins](https://github.com/mrkhachaturov/ccode-personal-plugins) | This repo — plugin marketplace |
| [rkstack](https://github.com/mrkhachaturov/rkstack) | Unified AI workflow skill packs (superpowers + gstack + custom) |
| [cc-skills](https://github.com/mrkhachaturov/cc-skills) | Fork of Anthropic example skills (pdf, docx, design) |
| [claude-audit-plugin](https://github.com/mrkhachaturov/claude-audit-plugin) | AI-readiness audit plugin |

## Commands

```bash
# Sync with Anthropic upstream
./.github/scripts/sync-upstream.sh

# Install a plugin in a project
/plugin install {plugin-name}@ccode-personal-plugins
```
