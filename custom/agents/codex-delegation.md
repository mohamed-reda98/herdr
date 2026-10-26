## Codex delegation — dispatch through the Herdr wrapper

When using the `codex-delegate` skill, dispatch with `herdr-codex-relay` instead
of calling `relay.mjs` directly. Same arguments, same output, same exit code:

```bash
herdr-codex-relay --brief brief.txt --cd /path/to/repo
```

Rather than (as SKILL.md step 2 shows):

```bash
node "<skill-dir>/scripts/relay.mjs" --brief brief.txt --cd /path/to/repo
```

Reason: `relay.mjs` runs `codex exec` headless, so Herdr's screen-scraping
detection never sees a "working" signal and marks the pane done while Codex is
still running. The wrapper reports the state to Herdr explicitly and releases it
when the run ends. Outside a Herdr pane it is a transparent pass-through.

Everything else in the skill is unchanged — brief, `result.json`, review, commit.

### Live progress while Codex works

Right after dispatching (relay in the background), start a Monitor on the feed:

```
Monitor(command: "herdr-delegate-feed progress --interval 120",
        description: "codex delegate progress", timeout_ms: 1800000)
```

It prints one summary line every 2 minutes and a final `[codex finished: …]` line.
For each line, give the user a short comment (1–2 sentences) on what Codex is
doing now — its current step, commands, files edited, failures — in your own
words, not a paste of the line. If the monitor expires while the relay is still
running, re-arm it with the same command (it resumes without repeating). Stop
commenting once the finished line arrives and continue with the review.

In the first comment, tell the user they can click the "👁 codex" tab that appears
in the tab bar (or press `Ctrl+b` then `Alt+w` for a popup) to see the live
viewer — the full brief, Codex's thinking, commands and output.
Do not post a clickable link to it — Herdr does not route those clicks.
