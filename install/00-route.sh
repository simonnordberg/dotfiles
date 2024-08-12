connections=("Mumindalen 24/7" "enp195s0f4u1u6")
destination="192.168.5.0/24"
gateway="192.168.2.1"

check_route() {
  nmcli connection show "$1" | grep -w "$destination" >/dev/null 2>&1
}

for connection in "${connections[@]}"; do
  if check_route "$connection"; then
    echo "Route $destination via $gateway already exists for connection $connection."
  else
    nmcli connection modify "$connection" +ipv4.routes "$destination $gateway"
    nmcli connection down "$connection"
    nmcli connection up "$connection"
    echo "Added route $destination via $gateway to connection $connection."
  fi
done
