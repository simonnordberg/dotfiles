sudo dnf install -y dnf-plugins-core
sudo dnf config-manager addrepo --overwrite --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install -y brave-browser
