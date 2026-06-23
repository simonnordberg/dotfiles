sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo tee /etc/yum.repos.d/1password.repo >/dev/null <<EOF
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
sudo dnf install -y 1password 1password-cli

# File dialog requires ptrace_scope=1 for xdg-desktop-portal process verification
sudo tee /etc/sysctl.d/99-ptrace-scope.conf >/dev/null <<EOF
kernel.yama.ptrace_scope=1
EOF
sudo sysctl --system >/dev/null
