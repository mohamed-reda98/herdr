#!/usr/bin/env bash
# Toggles the viewer popup (from Ctrl+b Alt+w, the plugin action, or the 👁 button bar).
set -uo pipefail

# Toggle: if a viewer is already open, close it instead of opening another.
# The viewer records its PID; the popup closes when its command exits.
pid_file="${HERDR_DELEGATE_STATE:-$HOME/.local/state/herdr-delegate}/viewer.pid"
if [ -f "$pid_file" ]; then
    pid=$(cat "$pid_file" 2>/dev/null)
    if [ -n "$pid" ] && grep -qa "herdr-delegate-feed" "/proc/$pid/cmdline" 2>/dev/null; then
        kill -TERM "$pid" 2>/dev/null
        exit 0
    fi
fi
# Which run to show: the pane passed by the 👁 button bar, else the focused pane.
pane="${HERDR_DELEGATE_PANE:-}"
if [ -z "$pane" ] && [ -n "${HERDR_PLUGIN_CONTEXT_JSON:-}" ]; then
    pane=$(python3 -c 'import json,os; print(json.loads(os.environ["HERDR_PLUGIN_CONTEXT_JSON"]).get("focused_pane_id") or "")')
fi
open_args=(--plugin delegate-watch --entrypoint viewer --env "HERDR_DELEGATE_PANE=$pane" --focus)
# Herdr 0.8's `plugin pane open --help` omits popup sizing while the API accepts
# it; try explicit popup placement, then fall back to the manifest's own
# placement (popup, 85%×85%) if this CLI build rejects the flags.
herdr plugin pane open "${open_args[@]}" --placement popup --width 85% --height 85% ||
    herdr plugin pane open "${open_args[@]}"
