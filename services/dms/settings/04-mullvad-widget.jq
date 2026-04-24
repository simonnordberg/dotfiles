# Add mullvadCheck plugin widget to the right side of the bar.
# Bar widgets can be plain strings (default config) or objects with id + extra fields.
.barConfigs[0].rightWidgets |=
  if any(
    (type == "string" and . == "mullvadCheck") or
    (type == "object" and .id == "mullvadCheck")
  ) then .
  else . + [{"id": "mullvadCheck", "enabled": true}]
  end
