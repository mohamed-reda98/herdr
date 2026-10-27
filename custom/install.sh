#!/usr/bin/env bash
# Install the customizations in this directory by linking them in place, so
# edits in the repo take effect without copying. Safe to re-run.
#
#   custom/install.sh           link scripts and plugin, report config status
#   custom/install.sh --config  also link config.toml (backs up an existing one)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="$HOME/.local/bin"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"
link_config=0
[ "${1:-}" = "--config" ] && link_config=1

# Replaces $2 with a symlink to $1, keeping a regular file as $2.bak.
link() {
    if [ -e "$2" ] && [ ! -L "$2" ]; then
        mv "$2" "$2.bak"
        echo "backed up $2 -> $2.bak"
    fi
    ln -sfn "$1" "$2"
    echo "linked $2 -> $1"
}

mkdir -p "$bin_dir"
for script in herdr-codex-relay herdr-delegate-feed; do
    link "$here/bin/$script" "$bin_dir/$script"
done

if command -v herdr >/dev/null; then
    herdr plugin unlink delegate-watch >/dev/null 2>&1 || true
    herdr plugin link "$here/plugins/delegate-watch"
else
    echo "herdr not found on PATH; link the plugin later with:"
    echo "  herdr plugin link \"$here/plugins/delegate-watch\""
fi

if [ "$link_config" = 1 ]; then
    mkdir -p "$config_dir"
    link "$here/config/config.toml" "$config_dir/config.toml"
elif ! cmp -s "$here/config/config.toml" "$config_dir/config.toml" 2>/dev/null; then
    echo "config.toml differs from $config_dir/config.toml; merge it by hand or re-run with --config"
fi

echo "agent rule: add $here/agents/codex-delegation.md to your global CLAUDE.md or AGENTS.md"
