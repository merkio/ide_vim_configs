#!/usr/bin/env bash
# Установка Pi и конфигов: bash setup-pi.sh
# Кладёт settings.json и models.json в ~/.pi/agent (старые — в резервную копию),
# подключает zsh-блок и kitty-конфиг. Ключи и пароли скрипт НЕ создаёт и не хранит.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
agent_dir="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
ts="$(date +%s)"

# 1) Pi (без выполнения скриптов зависимостей)
if ! command -v pi >/dev/null 2>&1; then
  command -v npm >/dev/null 2>&1 || { echo "Нужен Node.js/npm (Node 22+)"; exit 1; }
  npm install -g --ignore-scripts @earendil-works/pi-coding-agent
fi

# 2) Конфиги Pi
mkdir -p "$agent_dir"
for f in settings.json models.json; do
  [ -f "$agent_dir/$f" ] && cp "$agent_dir/$f" "$agent_dir/$f.bak.$ts"
  cp "$here/pi/$f" "$agent_dir/$f"
done
[ -f "$agent_dir/auth.json" ] && chmod 600 "$agent_dir/auth.json"

# 3) zsh и kitty
if ! grep -q "zshrc-tmux.zsh" ~/.zshrc 2>/dev/null; then
  cp "$here/zshrc-tmux.zsh" ~/zshrc-tmux.zsh
  printf '\n# tmux/zsh/kitty\nsource ~/zshrc-tmux.zsh\n' >> ~/.zshrc
fi
mkdir -p ~/.config/kitty
cp "$here/kitty-tmux.conf" ~/.config/kitty/kitty-tmux.conf
grep -q "kitty-tmux.conf" ~/.config/kitty/kitty.conf 2>/dev/null || \
  printf '\ninclude kitty-tmux.conf\n' >> ~/.config/kitty/kitty.conf

# 4) workmux
bash "$here/workmux/setup-workmux.sh"

cat <<EOF

Готово. Дальше, внутри Pi (команда: pi):
  /login            → Anthropic (подписка Claude или API-ключ)
  /login            → GitHub Copilot (вход через браузер/код устройства)
  /login            → Mistral (API-ключ; либо переменная MISTRAL_API_KEY)
  /model            → выберите модель, Ctrl+S — сохранить как стартовую
  /scoped-models    → какие модели переключаются по Ctrl+P

Ollama (локально):
  ollama pull qwen2.5-coder:7b
  OLLAMA_CONTEXT_LENGTH=32768 ollama serve     # иначе контекст может быть мал
  затем /model → provider "ollama"

Перезапустите tmux (tmux kill-server — сохраните работу!) и kitty.
EOF
