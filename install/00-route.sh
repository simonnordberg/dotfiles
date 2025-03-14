gateway="192.168.2.1"
routes=("192.168.5.0/24" "192.168.4.0/24" "192.168.6.0/24")
wired_interface="enp195s0f3u1u6"
wired_profile="Mumindalen Wired"
wired_metric=50
wifi_ssid="Mumindalen 24/7"
wifi_metric=200

# Check if a connection exists
conn_exists() {
  nmcli connection show "$1" >/dev/null 2>&1
}

# Configure wired connection
setup_wired() {
  echo "Setting up wired profile: $wired_profile"
  if conn_exists "$wired_profile"; then
    echo "Updating wired profile: $wired_profile"
    nmcli connection modify "$wired_profile" ipv4.routes ""
  else
    echo "Creating wired profile: $wired_profile"
    nmcli connection add type ethernet ifname "$wired_interface" con-name "$wired_profile" ipv4.method auto
  fi

  for route in "${routes[@]}"; do
    nmcli connection modify "$wired_profile" +ipv4.routes "$route $gateway $wired_metric"
    echo "Added route $route via $gateway with metric $wired_metric to $wired_profile"
  done

  nmcli connection down "$wired_profile"
  nmcli connection up "$wired_profile"
}

# Configure Wi-Fi connection
setup_wifi() {
  echo "Setting up Wi-Fi: $wifi_ssid"
  if conn_exists "$wifi_ssid"; then
    nmcli connection modify "$wifi_ssid" ipv4.routes ""
    for route in "${routes[@]}"; do
      nmcli connection modify "$wifi_ssid" +ipv4.routes "$route $gateway $wifi_metric"
      echo "Added route $route via $gateway with metric $wifi_metric to $wifi_ssid"
    done

    nmcli connection down "$wifi_ssid"
    nmcli connection up "$wifi_ssid"
  else
    echo "Wi-Fi '$wifi_ssid' not found. Skipping."
  fi
}

setup_wired
setup_wifi
