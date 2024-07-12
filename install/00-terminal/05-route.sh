INTERFACE="enp195s0f4u1u6"
DESTINATION="192.168.5.0/24"
GATEWAY="192.168.2.1"

check_route() {
	nmcli connection show "$INTERFACE" | grep -w "$DESTINATION" >/dev/null 2>&1
}

# Main script logic
if check_route; then
	echo "Route $DESTINATION via $GATEWAY already exists for connection $INTERFACE."
else
	nmcli connection modify "$INTERFACE" +ipv4.routes "$DESTINATION $GATEWAY"
	nmcli connection down "$INTERFACE"
	nmcli connection up "$INTERFACE"
	echo "Added route $DESTINATION via $GATEWAY to connection $INTERFACE."
fi
