SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SETTINGS="$HOME/.config/DankMaterialShell/settings.json"
CHASSIS="$(hostnamectl chassis 2>/dev/null || echo "desktop")"

if [ ! -f "$SETTINGS" ]; then
  echo "DMS settings.json not found, skipping patches"
  exit 0
fi

declare -A patches
for f in "$SCRIPT_DIR"/patches/*.jq; do
  [ -f "$f" ] || continue
  patches["$(basename "$f")"]="$f"
done
if [ -d "$SCRIPT_DIR/patches.$CHASSIS" ]; then
  for f in "$SCRIPT_DIR/patches.$CHASSIS"/*.jq; do
    [ -f "$f" ] || continue
    patches["$(basename "$f")"]="$f"
  done
fi

tmp="$(mktemp)"
cp "$SETTINGS" "$tmp"
for name in $(printf '%s\n' "${!patches[@]}" | sort); do
  jq -f "${patches[$name]}" "$tmp" > "$tmp.out" && mv "$tmp.out" "$tmp"
done
cp "$tmp" "$SETTINGS"
rm -f "$tmp" "$tmp.out"

echo "Applied ${#patches[@]} DMS patches (chassis: $CHASSIS)"
