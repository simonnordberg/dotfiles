sudo dnf config-manager addrepo --overwrite --from-repofile=https://repository.mullvad.net/rpm/beta/mullvad.repo
sudo dnf install -y mullvad-vpn

mkdir -p $HOME/.config/autostart
ln -fsn /usr/share/applications/mullvad-vpn.desktop $HOME/.config/autostart
