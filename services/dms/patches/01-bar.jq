# Add keyboard_layout_name widget to center bar if not already present
.barConfigs[0].centerWidgets |=
  if any(type == "object" and .id == "keyboard_layout_name") then .
  else . + [{"id": "keyboard_layout_name", "enabled": true, "keyboardLayoutNameCompactMode": false}]
  end
