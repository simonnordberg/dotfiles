if ! command -v scw &> /dev/null; then
    VERSION=$(curl -fsSL https://api.github.com/repos/scaleway/scaleway-cli/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) ARCH=amd64 ;;
        aarch64) ARCH=arm64 ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT

    curl -fsSL -o "$TMP/scw" "https://github.com/scaleway/scaleway-cli/releases/download/v${VERSION}/scaleway-cli_${VERSION}_linux_${ARCH}"
    sudo install -m 0755 "$TMP/scw" /usr/local/bin/scw
else
    echo "Scaleway CLI is already installed"
fi

mkdir -p "$HOME/.zsh/completions"
scw autocomplete script shell=zsh > "$HOME/.zsh/completions/_scw"
