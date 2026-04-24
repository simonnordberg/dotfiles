SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CHASSIS="$(hostnamectl chassis 2>/dev/null || echo "desktop")"

sudo dnf copr enable avengemedia/dms -y
sudo dnf install dms -y
systemctl --user add-wants niri.service dms

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

install_plugins() {
  local src="$SCRIPT_DIR/plugins"
  local dst="$HOME/.config/DankMaterialShell/plugins"
  [ -d "$src" ] || return

  mkdir -p "$dst"
  local needs_restart=false
  for dir in "$src"/*/; do
    [ -d "$dir" ] || continue
    local name
    name="$(basename "$dir")"
    rm -rf "$dst/$name"
    cp -r "$dir" "$dst/$name"
    local pid
    pid="$(jq -r '.id' "$dir/plugin.json" 2>/dev/null)"
    echo "  Installed plugin: $name (id: ${pid:-?})"
    if [ -n "$pid" ] && [ "$pid" != "null" ]; then
      # reload only works for plugins already in availablePlugins; the
      # FolderListModel watcher misses brand-new dirs added while the shell
      # is running, so fall back to a full restart in that case.
      if ! dms ipc call plugins reload "$pid" 2>&1 | grep -q "^PLUGIN_RELOAD_SUCCESS"; then
        needs_restart=true
      fi
    fi
  done

  if [ "$needs_restart" = true ] && systemctl --user is-active --quiet dms; then
    echo "  Restarting dms to load new plugins..."
    systemctl --user restart dms
  fi
}

echo "Installing DMS plugins..."
install_plugins

echo "Patching DMS config (chassis: $CHASSIS)..."
apply_patches "$HOME/.config/DankMaterialShell/settings.json" "$SCRIPT_DIR/settings"
apply_patches "$HOME/.config/DankMaterialShell/plugin_settings.json" "$SCRIPT_DIR/plugin-settings"
apply_patches "$HOME/.local/state/DankMaterialShell/session.json" "$SCRIPT_DIR/session"
