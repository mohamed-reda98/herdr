# Custom additions

Local additions on top of upstream Herdr, kept in this fork so they are
versioned. Nothing here changes Herdr's own source; it all runs beside a stock
Herdr build.

## Delegated Codex runs

When Claude Code hands work to Codex with the `codex-delegate` skill, Codex
runs headless (`codex exec`). Herdr's screen detection never sees it working,
so the pane reads "done" while Codex is still busy, and there is no way to
watch the run. These pieces fix that.

| Path | What it does |
|---|---|
| `bin/herdr-codex-relay` | Drop-in wrapper for the skill's `relay.mjs`. Reports the delegated state to Herdr, registers the run, opens a "👁 codex" tab, clears the state on exit (even after SIGKILL), and stops the run when the dispatching Claude session ends. |
| `bin/herdr-delegate-feed` | Reads the run's event stream. `view` is a live tail for a human; `progress` prints one summary line per interval for the orchestrating agent. |
| `plugins/delegate-watch/` | Herdr plugin whose action toggles a popup running `herdr-delegate-feed view`. |
| `config/config.toml` | `prefix+alt+w` toggles the viewer; Claude rows in the sidebar show the `delegate` token. |
| `agents/codex-delegation.md` | Instructions for the orchestrating agent: dispatch through the wrapper and follow the run with `progress`. |

Requirements: Herdr 0.8 or newer, `bash`, `python3`, `node`, and the
`codex-delegate` skill at `~/.claude/skills/codex-delegate` (override with
`CODEX_DELEGATE_RELAY`).

## Install

```bash
custom/install.sh            # link the scripts into ~/.local/bin and link the plugin
custom/install.sh --config   # also link config.toml, backing up the existing one
```

Then add `agents/codex-delegation.md` to your global `CLAUDE.md` or
`AGENTS.md`.

## Use

- Dispatch: `herdr-codex-relay --brief brief.txt --cd /path/to/repo`
- Watch: click the "👁 codex" tab, or press `Ctrl+b` then `Alt+w`
- Follow from an agent: `herdr-delegate-feed progress --interval 120`

Set `HERDR_RELAY_DEBUG=1` to print the Herdr reporting commands. The header
of `bin/herdr-codex-relay` lists the other environment overrides.
