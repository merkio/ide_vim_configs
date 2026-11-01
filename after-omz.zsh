# Подключайте в КОНЕЦ ~/.zshrc (после строки `source $ZSH/oh-my-zsh.sh`).
# Блок не дублирует то, что уже дают ваши плагины oh-my-zsh.
#
# Что добавьте в ваш массив plugins (в .zshrc, ДО source $ZSH/oh-my-zsh.sh):
#   plugins=( ...ваши... tmux )          # даёт алиасы ta, tl, ts, tad, tkss, tksv
#   (по желанию)  vi-mode  fzf  zoxide
# Автозапуск плагина tmux ОТКЛЮЧЁН — им занимается mac/autostart.zsh:
#   export ZSH_TMUX_AUTOSTART=false     # поставьте ПЕРЕД source $ZSH/oh-my-zsh.sh
# zsh-syntax-highlighting должен оставаться последним в списке plugins.

# vim-режим командной строки — только если нет плагина vi-mode
if ! (( ${plugins[(Ie)vi-mode]} )); then
  bindkey -v
  export KEYTIMEOUT=1
  bindkey '^R' history-incremental-search-backward
fi

# fzf (Ctrl+R / Ctrl+T / Alt+C) — только если нет плагина fzf
if ! (( ${plugins[(Ie)fzf]} )) && command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)                    # fzf 0.48+
fi

# zoxide — только если нет плагина zoxide
if ! (( ${plugins[(Ie)zoxide]} )) && command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Алиасы для агентов (ta/tl/ts уже есть в плагине tmux)
alias wm='workmux'
alias lg='lazygit'
