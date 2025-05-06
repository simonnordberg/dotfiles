if [ -d /opt/calibre ]; then
    echo "calibre is already installed"
    exit 0
fi

sudo -v && curl -k -s https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin install_dir=/opt
