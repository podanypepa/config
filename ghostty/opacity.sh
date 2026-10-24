#!/bin/sh
# Zmena background-opacity v Ghostty za behu: opacity.sh up|down|reset
# Hodnota se uklada do ~/.config/ghostty/opacity (nacita ho config pres config-file),
# pak se pres AppleScript zavola reload_config.
file="$HOME/.config/ghostty/opacity"
step=0.05
default=0.4

cur=$(sed -n 's/^background-opacity *= *//p' "$file" 2>/dev/null)
[ -z "$cur" ] && cur=$default

case "$1" in
  up)   new=$(echo "$cur + $step" | bc) ;;
  down) new=$(echo "$cur - $step" | bc) ;;
  reset) new=$default ;;
  *)    echo "usage: $0 up|down|reset" >&2; exit 1 ;;
esac

# Rozsah 0.1 - 1.0
new=$(echo "if ($new > 1) 1 else if ($new < 0.1) 0.1 else $new" | bc)
new=$(printf '%.2f' "$new")

echo "background-opacity = $new" > "$file"
osascript -e 'tell application "Ghostty" to perform action "reload_config" on focused terminal of selected tab of front window' >/dev/null
command -v tmux >/dev/null && tmux display "opacity $new" 2>/dev/null
exit 0
