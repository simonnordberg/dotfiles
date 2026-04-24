# Mark mullvadCheck plugin enabled so it loads on DMS start
.mullvadCheck = ((.mullvadCheck // {}) | .enabled = true)
