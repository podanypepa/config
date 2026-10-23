#!/usr/bin/env bash
# Vyber tmux session nebo adresar (git repa v ROOTS + zoxide) pres fzf; adresar dostane vlastni session.
ROOTS=("$HOME/src" "$HOME/switchly.ai")

projects() {
	fd -H -t d --max-depth 3 '^\.git$' "${ROOTS[@]}" 2>/dev/null | sed 's|/\.git/*$||' | sort
}

# Nahled: session = jeji okna, adresar = obsah
preview='p={}; d="${p/#\~/$HOME}"
if [ -d "$d" ]; then eza -1 --icons --group-directories-first --color=always "$d"
else tmux list-windows -t "=$p" -F "#{window_index}: #{window_name}  #{pane_current_path}" | sed "s|$HOME|~|"; fi'

sel=$({ tmux list-sessions -F '#S'; projects; zoxide query -l 2>/dev/null; } |
	awk '!seen[$0]++' | sed "s|^$HOME|~|" |
	fzf --reverse --height=100% --prompt 'session> ' --info=inline-right \
		--preview "$preview" --preview-window 'right:40%:border-left' \
		--color 'bg:-1,bg+:#262626,gutter:-1,border:#444444') || exit 0
sel=${sel/#\~/$HOME}

if tmux has-session -t "=$sel" 2>/dev/null; then
	tmux switch-client -t "=$sel"
	exit
fi

name=$(basename "$sel" | tr '.:' '__')
tmux has-session -t "=$name" 2>/dev/null || tmux new-session -ds "$name" -c "$sel"
tmux switch-client -t "=$name"
