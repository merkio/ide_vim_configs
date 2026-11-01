# Добавьте в ~/.zshrc:   source ~/zshrc-tmux.zsh   (или вставьте содержимое в конец ~/.zshrc)

# ───────── Автозапуск tmux в kitty ─────────
# Условия: интерактивный шелл, мы в kitty, не внутри tmux, не по SSH.
# Отключить разово:  NO_TMUX=1 kitty     (или в окне:  NO_TMUX=1 zsh)
_tmux_autostart() {
  command -v tmux >/dev/null 2>&1 || return 0
  if tmux has-session -t main 2>/dev/null; then
    if [[ -z "$(tmux list-clients -t main 2>/dev/null)" ]]; then
      exec tmux attach -t main                       # первое окно kitty: возвращаемся в main
    else
      # второе окно kitty: своя сессия в группе main (общие окна, независимый выбор),
      # удаляется при закрытии окна kitty
      exec tmux new-session -t main -s "k${KITTY_WINDOW_ID:-$$}" \; set-option destroy-unattached on
    fi
  else
    exec tmux new-session -s main
  fi
}
if [[ -o interactive && -z "$TMUX" && -n "$KITTY_WINDOW_ID" && -z "$SSH_CONNECTION" && -z "$NO_TMUX" ]]; then
  _tmux_autostart
fi

# ───────── vim-режим в zsh (совместим с vim-клавишами tmux) ─────────
bindkey -v
export KEYTIMEOUT=1                                   # Esc без задержки
bindkey '^R' history-incremental-search-backward      # Ctrl+R работает и в vi-режиме
bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'j' down-line-or-history

# ───────── История ─────────
HISTFILE=~/.zsh_history; HISTSIZE=50000; SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# ───────── Утилиты (если установлены) ─────────
command -v fzf >/dev/null    && source <(fzf --zsh)   # нужен fzf 0.48+; Ctrl+R/Ctrl+T/Alt+C
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ───────── Алиасы для tmux и агентов ─────────
alias ta='tmux attach -t main || tmux new -s main'
alias tl='tmux list-sessions'
alias wm='workmux'
alias lg='lazygit'
