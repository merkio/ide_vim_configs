#!/usr/bin/env bash
# macOS + iTerm2 + oh-my-zsh.   Запуск из папки с файлами:
#   bash mac/setup-mac.sh zsh       # tmux стартует в КАЖДОМ окне iTerm2 (по умолчанию)
#   bash mac/setup-mac.sh profile   # отдельный профиль iTerm2 "tmux + агенты"; обычные окна без tmux
# Нужны: Homebrew, oh-my-zsh. Секреты скрипт не создаёт. Старые файлы сохраняются как *.bak.<время>.
set -euo pipefail

MODE="${1:-zsh}"
case "$MODE" in zsh|profile) ;; *) echo "Режим: zsh | profile"; exit 1;; esac

here="$(cd "$(dirname "$0")/.." && pwd)"          # корень набора файлов
ts="$(date +%s)"
agent_dir="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
cfg="$HOME/.config/tmux-iterm"

command -v brew >/dev/null 2>&1 || { echo "Нужен Homebrew: https://brew.sh"; exit 1; }

# 1) Пакеты
brew install tmux git fzf ripgrep fd bat zoxide lazygit btop node

# 2) tmux.conf (с бэкапом)
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf ~/.tmux.conf.bak."$ts"
cp "$here/tmux.conf" ~/.tmux.conf

# 3) Pi + конфиги (без выполнения скриптов зависимостей)
command -v pi >/dev/null 2>&1 || npm install -g --ignore-scripts @earendil-works/pi-coding-agent
mkdir -p "$agent_dir"
for f in settings.json models.json; do
  [ -f "$agent_dir/$f" ] && cp "$agent_dir/$f" "$agent_dir/$f.bak.$ts"
  cp "$here/pi/$f" "$agent_dir/$f"
done
[ -f "$agent_dir/auth.json" ] && chmod 600 "$agent_dir/auth.json"

# 4) zsh / oh-my-zsh
mkdir -p "$cfg"
cp "$here/mac/autostart.zsh" "$here/mac/after-omz.zsh" "$cfg/"
touch ~/.zshrc
cp ~/.zshrc ~/.zshrc.bak."$ts"

if [ "$MODE" = "zsh" ] && ! grep -q "tmux-iterm/autostart.zsh" ~/.zshrc; then
  { echo '# tmux autostart (iTerm2) — должен быть первым'
    echo 'source ~/.config/tmux-iterm/autostart.zsh'
    cat ~/.zshrc; } > ~/.zshrc.new && mv ~/.zshrc.new ~/.zshrc
fi
if ! grep -q "tmux-iterm/after-omz.zsh" ~/.zshrc; then
  printf '\n# tmux/iTerm2 доп. настройки (после oh-my-zsh)\nsource ~/.config/tmux-iterm/after-omz.zsh\n' >> ~/.zshrc
fi

# 5) Профиль iTerm2 (режим profile)
if [ "$MODE" = "profile" ]; then
  d="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$d"
  cp "$here/mac/iterm2-tmux-profile.json" "$d/tmux-agents.json"
  echo "Профиль 'tmux + агенты' появится в iTerm2 > Profiles."
fi

# 6) workmux (parallel agents in tmux windows + git worktrees)
bash "$here/workmux/setup-workmux.sh"

cat <<'EOF'

Готово. Осталось вручную (iTerm2 > Settings, Cmd+,):
  1. Profiles > Keys > General: Left Option Key = Esc+   (нужно для Alt+Enter в Pi, Alt+b/f в zsh)
  2. General > Selection: включите "Applications in terminal may access clipboard"
     (копирование из tmux по OSC 52, в т.ч. по SSH)
  3. Добавьте tmux в plugins=(...) в ~/.zshrc и перед oh-my-zsh.sh: export ZSH_TMUX_AUTOSTART=false
     Подробности — в mac/after-omz.zsh.
Затем: tmux kill-server (сохраните работу!), закройте и откройте iTerm2. Pi: команда pi, дальше /login.
EOF
