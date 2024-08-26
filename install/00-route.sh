connections=("Mumindalen 24/7" "enp195s0f4u1u6")
destinations=("192.168.5.0/24" "192.168.4.0/24")
gateway="192.168.2.1"

check_route() {
  nmcli connection show "$1" | grep -w "$2" >/dev/null 2>&1
}

for connection in "${connections[@]}"; do
  for destination in "${destinations[@]}"; do
    if check_route "$connection" "$destination"; then
      echo "Route $destination via $gateway already exists for connection $connection."
    else
      nmcli connection modify "$connection" +ipv4.routes "$destination $gateway"
      nmcli connection down "$connection"
      nmcli connection up "$connection"
      echo "Added route $destination via $gateway to connection $connection."
    fi
  done
done
