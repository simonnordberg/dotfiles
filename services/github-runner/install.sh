#!/bin/bash
set -e

if [ "$(hostname)" != "flynn" ]; then
  echo "Skipping github-runner setup (hostname: $(hostname))"
  exit 0
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

APP_DIR=/var/lib/github-runner
RUNNER_NAME="${RUNNER_NAME:-flynn}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,Linux,X64,flynn}"
RUNNER_VERSION="${RUNNER_VERSION:-2.334.0}"

# Prompt for credentials only on first install. Once registered, the runner
# stores long-lived credentials under $APP_DIR/.credentials.
if ! sudo test -f "$APP_DIR/.runner"; then
  if [ -z "${GITHUB_URL:-}" ]; then
    read -r -p "GitHub URL (e.g. https://github.com/hackerman-co): " GITHUB_URL
  fi
  if [ -z "${RUNNER_TOKEN:-}" ]; then
    read -r -s -p "Runner registration token: " RUNNER_TOKEN
    echo
  fi
  if [ -z "$GITHUB_URL" ] || [ -z "$RUNNER_TOKEN" ]; then
    echo "GITHUB_URL and RUNNER_TOKEN are required" >&2
    exit 1
  fi
fi

export SCRIPT_DIR APP_DIR GITHUB_URL RUNNER_TOKEN RUNNER_NAME RUNNER_LABELS RUNNER_VERSION

sudo -E bash <<'EOF'
set -euo pipefail

RUNNER_USER=github-runner

dnf install -y libicu tar curl policycoreutils-python-utils

if ! id -u "$RUNNER_USER" >/dev/null 2>&1; then
  useradd --system --create-home --home-dir "$APP_DIR" --shell /bin/bash "$RUNNER_USER"
fi

# Workflows commonly need docker; group membership is effectively root, so
# only register this runner on trusted (private) repos.
if getent group docker >/dev/null && ! id -nG "$RUNNER_USER" | grep -qw docker; then
  usermod -aG docker "$RUNNER_USER"
fi

mkdir -p "$APP_DIR"
chown "$RUNNER_USER:$RUNNER_USER" "$APP_DIR"

if [ ! -x "$APP_DIR/config.sh" ]; then
  URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
  sudo -u "$RUNNER_USER" bash -c "
    set -euo pipefail
    cd '$APP_DIR'
    curl -fsSLo runner.tar.gz '$URL'
    tar xzf runner.tar.gz
    rm runner.tar.gz
  "
fi

if [ ! -f "$APP_DIR/.runner" ]; then
  sudo -u "$RUNNER_USER" "$APP_DIR/config.sh" \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work _work \
    --unattended \
    --replace
fi

UNIT_PATH=/etc/systemd/system/github-runner.service
cp "$SCRIPT_DIR/github-runner.service" "$UNIT_PATH"
chmod 664 "$UNIT_PATH"

# Files under /var/lib default to a SELinux type init can't exec. Label the
# runner tree as bin_t so systemd can launch runsvc.sh.
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Enforcing" ]; then
  restorecon -v "$UNIT_PATH"
  semanage fcontext -a -t bin_t "${APP_DIR}(/.*)?" 2>/dev/null \
    || semanage fcontext -m -t bin_t "${APP_DIR}(/.*)?"
  restorecon -R "$APP_DIR"
fi

systemctl daemon-reload
systemctl enable github-runner
systemctl restart github-runner || systemctl start github-runner
EOF
