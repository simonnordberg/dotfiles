#!/bin/bash
set -euo pipefail

if [ "$(hostname)" != "flynn" ]; then
  echo "Skipping codebahn-runner (host: $(hostname))"
  exit 0
fi

echo "Setting up Codebahn (Forgejo) Actions runner..."

export SERVICE_DIR="$(dirname "$(readlink -f "$0")")"

sudo -E -u root bash <<'EOF'
set -euo pipefail

RUNNER_USER=forgejo-runner
APP_DIR=/srv/apps/forgejo-runner

dnf install -y curl jq policycoreutils-python-utils

if ! id -u "$RUNNER_USER" >/dev/null 2>&1; then
  useradd --system --create-home --home-dir "$APP_DIR" --shell /bin/bash "$RUNNER_USER"
fi

HOME_DIR=$(getent passwd "$RUNNER_USER" | cut -d: -f6)
if [ -n "$HOME_DIR" ] && [ ! -d "$HOME_DIR" ]; then
  install -d -o "$RUNNER_USER" -g "$RUNNER_USER" -m 0750 "$HOME_DIR"
fi

if getent group docker >/dev/null && ! id -nG "$RUNNER_USER" | grep -qw docker; then
  usermod -aG docker "$RUNNER_USER"
fi

mkdir -p "$APP_DIR"
chown "$RUNNER_USER:$RUNNER_USER" "$APP_DIR"

ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
RUNNER_VERSION=$(curl -fsSL 'https://data.forgejo.org/api/v1/repos/forgejo/runner/releases/latest' | jq .name -r | cut -c 2-)

CACHE_BIN="/var/cache/forgejo-runner-${RUNNER_VERSION}"
if [ ! -f "$CACHE_BIN" ]; then
  URL="https://code.forgejo.org/forgejo/runner/releases/download/v${RUNNER_VERSION}/forgejo-runner-${RUNNER_VERSION}-linux-${ARCH}"
  mkdir -p "$(dirname "$CACHE_BIN")"
  curl -fsSLo "$CACHE_BIN" "$URL"
  chmod +x "$CACHE_BIN"
fi

install -m 0755 "$CACHE_BIN" "$APP_DIR/forgejo-runner"
echo "  forgejo-runner v${RUNNER_VERSION} (${ARCH})"

UNIT_PATH=/etc/systemd/system/forgejo-runner.service
cp "$SERVICE_DIR/forgejo-runner.service" "$UNIT_PATH"
chmod 644 "$UNIT_PATH"

if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Enforcing" ]; then
  if ! semanage fcontext -l 2>/dev/null | grep -q '/srv/apps/forgejo-runner'; then
    semanage fcontext -a -t bin_t '/srv/apps/forgejo-runner(/.*)?'
  fi
  restorecon -R "$APP_DIR"
  restorecon "$UNIT_PATH" 2>/dev/null || true
fi

systemctl daemon-reload
systemctl enable forgejo-runner.service

if [ -f "$APP_DIR/config.yml" ]; then
  systemctl restart forgejo-runner.service
  echo "  Codebahn runner started. Check: systemctl status forgejo-runner"
else
  echo "  Runner installed but not started. Run setup.sh to configure credentials."
fi
EOF
