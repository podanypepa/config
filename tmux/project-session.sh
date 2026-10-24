#!/usr/bin/env bash
# Zalozi tmux session pro adresar (pokud neni) a prepne/pripoji se do ni.
# Projekt (git repo, go.mod, package.json, pyproject.toml) dostane okna:
#   1 edit  = nvim, 2 shell, 3 run = predvyplneny prikaz podle typu (spusti se az Enterem)
# Jiny adresar = jedna obycejna session.
# Pouziti: project-session.sh [adresar]   (bez argumentu aktualni adresar)
dir=$(cd "${1:-$PWD}" && pwd) || exit 1
name=$(basename "$dir" | tr '.:' '__')

run_cmd() {
	if [[ -f $dir/go.mod || -f $dir/go.work ]]; then
		echo "go test ./..."
	elif [[ -f $dir/package.json ]]; then
		local pm=npm
		[[ -f $dir/pnpm-lock.yaml ]] && pm=pnpm
		[[ -f $dir/yarn.lock ]] && pm=yarn
		[[ -f $dir/bun.lock || -f $dir/bun.lockb ]] && pm=bun
		if grep -q '"dev"[[:space:]]*:' "$dir/package.json"; then
			echo "$pm run dev"
		elif grep -q '"test"[[:space:]]*:' "$dir/package.json"; then
			echo "$pm test"
		fi
	elif [[ -f $dir/pyproject.toml || -f $dir/requirements.txt ]]; then
		if [[ -f $dir/uv.lock ]]; then echo "uv run pytest"; else echo "pytest"; fi
	fi
}

if ! tmux has-session -t "=$name" 2>/dev/null; then
	run=$(run_cmd)
	if [[ -n $run || -e $dir/.git ]]; then
		tmux new-session -ds "$name" -c "$dir" -n edit
		tmux send-keys -t "=$name:edit" nvim Enter
		tmux new-window -d -t "=$name:" -n shell -c "$dir"
		tmux new-window -d -t "=$name:" -n run -c "$dir"
		[[ -n $run ]] && tmux send-keys -t "=$name:run" "$run"
	else
		tmux new-session -ds "$name" -c "$dir"
	fi
fi

if [[ -n $TMUX ]]; then
	tmux switch-client -t "=$name"
else
	tmux attach -t "=$name"
fi
