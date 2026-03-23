SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CHASSIS="$(hostnamectl chassis 2>/dev/null || echo "desktop")"

apply_patches() {
  local target="$1"
  local patch_dir="$2"

  if [ ! -f "$target" ]; then
    mkdir -p "$(dirname "$target")"
    echo '{}' > "$target"
  fi

  declare -A patches
  for f in "$patch_dir"/*.jq; do
    [ -f "$f" ] || continue
    patches["$(basename "$f")"]="$f"
  done
  if [ -d "$patch_dir.$CHASSIS" ]; then
    for f in "$patch_dir.$CHASSIS"/*.jq; do
      [ -f "$f" ] || continue
      patches["$(basename "$f")"]="$f"
    done
  fi

  if [ ${#patches[@]} -eq 0 ]; then
    return
  fi

  local tmp
  tmp="$(mktemp)"
  cp "$target" "$tmp"
  for name in $(printf '%s\n' "${!patches[@]}" | sort); do
    jq -f "${patches[$name]}" "$tmp" > "$tmp.out" && mv "$tmp.out" "$tmp"
  done
  cp "$tmp" "$target"
  rm -f "$tmp" "$tmp.out"

  echo "  Applied ${#patches[@]} patches to $(basename "$target")"
}

echo "Patching DMS config (chassis: $CHASSIS)..."
apply_patches "$HOME/.config/DankMaterialShell/settings.json" "$SCRIPT_DIR/settings"
apply_patches "$HOME/.local/state/DankMaterialShell/session.json" "$SCRIPT_DIR/session"
