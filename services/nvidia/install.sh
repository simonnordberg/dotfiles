# Check if NVIDIA GPU is present
if ! lspci | grep -i nvidia > /dev/null; then
    echo "No NVIDIA GPU detected - skipping NVIDIA driver installation"
    exit 0
fi

sudo dnf install -y \
    akmod-nvidia \
    xorg-x11-drv-nvidia-cuda