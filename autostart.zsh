# Автозапуск tmux в iTerm2.
# ВАЖНО: подключайте в САМОМ НАЧАЛЕ ~/.zshrc — до Powerlevel10k instant prompt и до oh-my-zsh.
# Тогда внешний шелл тратит минимум времени, а oh-my-zsh грузится уже внутри tmux.
#
# Отключить разово:        NO_TMUX=1 open -a iTerm   (или в окне: NO_TMUX=1 zsh)
# Нативная интеграция iTerm2 (tmux -CC): добавьте перед запуском  export TMUX_ITERM_CC=1

_tmux_autostart() {
  command -v tmux >/dev/null 2>&1 || return 0

  if [[ -n "$TMUX_ITERM_CC" ]]; then
    exec tmux -CC new-session -A -s main            # окна tmux показываются как вкладки iTerm2
  fi

  if tmux has-session -t main 2>/dev/null; then
    if [[ -z "$(tmux list-clients -t main 2>/dev/null)" ]]; then
      exec tmux attach -t main                      # первое окно iTerm2: возвращаемся в main
    else
      # следующие окна: своя сессия в группе main (общие окна, независимый выбор),
      # удаляется при закрытии окна iTerm2
      exec tmux new-session -t main -s "iterm$$" \; set-option destroy-unattached on
    fi
  else
    exec tmux new-session -s main
  fi
}

if [[ -o interactive && "$TERM_PROGRAM" == "iTerm.app" && -z "$TMUX" \
      && -z "$SSH_CONNECTION" && -z "$NO_TMUX" ]]; then
  _tmux_autostart
fi
