flatpak install -y flathub org.signal.Signal
flatpak override org.signal.Signal --user --env=SIGNAL_PASSWORD_STORE=gnome-libsecret
