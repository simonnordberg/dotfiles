function wsudo
    sudo -E env \
        WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
        XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
        DISPLAY=$DISPLAY \
        XAUTHORITY=$XAUTHORITY \
        $argv
end
