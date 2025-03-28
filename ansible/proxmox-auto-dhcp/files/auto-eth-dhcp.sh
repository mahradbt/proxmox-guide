#!/bin/bash

IFACE="$1"
LOG="/var/log/auto-eth-dhcp.log"
IFACE_FILE="/etc/network/interfaces"

echo "[$(date)] Auto DHCP triggered for $IFACE" >> "$LOG"

[[ -z "$IFACE" ]] && exit 1

grep -q "iface $IFACE inet" "$IFACE_FILE" && exit 0

echo -e "\nallow-hotplug $IFACE\niface $IFACE inet dhcp" >> "$IFACE_FILE"

echo "[$(date)] Bringing up $IFACE..." >> "$LOG"
ifup "$IFACE" >> "$LOG" 2>&1

sleep 5
if ping -c 1 -W 3 8.8.8.8 > /dev/null; then
    echo "[$(date)] $IFACE is online" >> "$LOG"
else
    echo "[$(date)] $IFACE failed to connect" >> "$LOG"
fi
