#!/usr/bin/env bash
# Vyber tmux session nebo adresar (git repa v ROOTS + zoxide) pres fzf; adresar dostane vlastni session.
ROOTS=("$HOME/src" "$HOME/switchly.ai")

projects() {
	fd -H -t d --max-depth 3 '^\.git$' "${ROOTS[@]}" 2>/dev/null | sed 's|/\.git/*$||' | sort
}

sel=$({ tmux list-sessions -F '#S'; projects; zoxide query -l 2>/dev/null; } | awk '!seen[$0]++' | fzf --reverse --prompt 'session> ') || exit 0

if tmux has-session -t "=$sel" 2>/dev/null; then
	tmux switch-client -t "=$sel"
	exit
fi

name=$(basename "$sel" | tr '.:' '__')
tmux has-session -t "=$name" 2>/dev/null || tmux new-session -ds "$name" -c "$sel"
tmux switch-client -t "=$name"
