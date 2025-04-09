#!/bin/bash

LOG="/var/log/auto-eth-dhcp.log"

# List all available interfaces
for iface in $(ls /sys/class/net/); do
    # Skip interfaces you don't want to touch
    if [[ "$iface" =~ ^(lo|vmbr.*|docker.*|tap.*|wlp.*|bonding_masters|enp92s0|eth.*)$ ]]; then
        continue
    fi

    # Skip if already has an IP
    if ip -4 addr show dev "$iface" | grep -q "inet "; then
        echo "[$(date)] $iface already has an IP, skipping." >> "$LOG"
        continue
    fi

    echo "[$(date)] Found candidate interface: $iface" >> "$LOG"

    # Try to obtain an IP via dhclient
    echo "[$(date)] Running dhclient on $iface..." >> "$LOG"
    dhclient -v "$iface" >> "$LOG" 2>&1
    sleep 1

    GATEWAY=$(grep "option routers" /var/lib/dhcp/dhclient.${iface}.leases | tail -n 1 | sed -E 's/.*routers ([0-9.]+);.*/\1/'
)
    if [ -z "$GATEWAY" ]; then
        GATEWAY=$(grep "option routers" /var/lib/dhcp/dhclient.leases | tail -n 1 | sed -E 's/.*routers ([0-9.]+);.*/\1/'
)
    fi

    if [ -n "$GATEWAY" ]; then
        echo "[$(date)] Deleting existing default route (if any)..." >> "$LOG"
        ip route del default >> "$LOG" 2>&1
        echo "[$(date)] Setting new default gateway via $GATEWAY on $iface" >> "$LOG"
        ip route add default via "$GATEWAY" dev "$iface" >> "$LOG" 2>&1
    else
        echo "[$(date)] Could not determine default gateway for $iface" >> "$LOG"
    fi

    # Check connectivity
    if ping -c 1 -W 2 8.8.8.8 > /dev/null; then
        echo "[$(date)] $iface is online and connected to the internet." >> "$LOG"
        exit 0
    else
        echo "[$(date)] $iface failed to connect to the internet." >> "$LOG"
        dhclient -r "$iface"  # Release any lease
    fi

    sleep 5
done

exit 0
