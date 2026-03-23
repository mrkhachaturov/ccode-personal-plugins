# ccode-personal-plugins

Personal Claude Code plugin directory that syncs with the [official marketplace](https://github.com/anthropics/claude-plugins-official) and adds my own plugins on top.

## How it works

A sync script fetches the latest plugin list from upstream, then applies my customizations:

- **Metadata** — overrides name and owner
- **Custom plugins** — appends my own plugin entries
- **Exclusions** — removes upstream plugins I don't need

Sync runs weekly via GitHub Actions cron, or manually with:

```bash
./.github/scripts/sync-upstream.sh
```

## Configuration

All config lives in `.github/scripts/`:

| File | Purpose |
| --- | --- |
| `custom-plugins.json` | My metadata and plugin entries to add |
| `exclude-plugins.txt` | Upstream plugins to remove (one per line, `#` for comments) |
| `sync-upstream.sh` | Sync script — fetches upstream, merges via `jq` |

### Adding a plugin

Add an entry to `.github/scripts/custom-plugins.json`:

```json
{
  "name": "my-plugin",
  "description": "What it does",
  "category": "development",
  "source": { "source": "url", "url": "https://github.com/..." },
  "homepage": "https://github.com/..."
}
```

### Excluding an upstream plugin

Add the plugin name to `.github/scripts/exclude-plugins.txt`:

```txt
some-plugin-i-dont-want
```

## Installation

```bash
/plugin install {plugin-name}@ccode-personal-plugins
```

## License

See each linked plugin for its respective license.
