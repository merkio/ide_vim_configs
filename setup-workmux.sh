#!/usr/bin/env bash
# Installs workmux and deploys its config + tmux bindings (macOS and Linux).
#   bash workmux/setup-workmux.sh
# Called automatically by mac/setup-mac.sh and setup-pi.sh. Safe to re-run; backups are *.bak.<time>.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
ts="$(date +%s)"
cfg_dir="${XDG_CONFIG_HOME:-$HOME/.config}/workmux"

# 1) Install (no curl|bash: use a package manager, or print manual instructions)
if ! command -v workmux >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install raine/workmux/workmux
  elif command -v cargo >/dev/null 2>&1; then
    cargo install workmux
  else
    echo "workmux not installed. Options:"
    echo "  brew install raine/workmux/workmux"
    echo "  cargo install workmux"
    echo "  or a pre-built binary: https://github.com/raine/workmux/releases/latest (verify the .sha256)"
  fi
fi

# 2) Global config
mkdir -p "$cfg_dir"
[ -f "$cfg_dir/config.yaml" ] && cp "$cfg_dir/config.yaml" "$cfg_dir/config.yaml.bak.$ts"
cp "$here/config.yaml" "$cfg_dir/config.yaml"

# 3) tmux key bindings (tmux.conf loads ~/.tmux.agents.conf if it exists)
[ -f ~/.tmux.agents.conf ] && cp ~/.tmux.agents.conf ~/.tmux.agents.conf.bak."$ts"
cp "$here/tmux-workmux.conf" ~/.tmux.agents.conf

# 4) zsh completions for oh-my-zsh (its custom/completions dir is on fpath)
if command -v workmux >/dev/null 2>&1 && [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
  comp="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/completions"
  mkdir -p "$comp"
  workmux completions zsh > "$comp/_workmux" && rm -f ~/.zcompdump*
fi

cat <<'EOF'

workmux is configured. Next steps:
  1. In tmux, run once:  workmux setup     (detects Pi, installs its status extension)
  2. In a git repo:      cp workmux/project.workmux.yaml .workmux.yaml   (optional, per project)
  3. Reload tmux config: prefix + r     (Ctrl+a, then r)
  4. Try:                workmux add my-first-task -p "Add a README section about setup"
Warning: workmux must run INSIDE tmux. `workmux setup` changes agent configs; read what it proposes.
EOF
