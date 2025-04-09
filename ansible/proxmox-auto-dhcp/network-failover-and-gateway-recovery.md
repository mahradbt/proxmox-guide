# 📄 **Automatic Network Failover and Default Gateway Recovery**

This setup includes a script and a systemd service + timer that automatically detects network failures on the primary interface and switches to an alternative interface (such as a USB Ethernet adapter) using DHCP. It ensures that the system always maintains internet connectivity in the event of cable disconnection or other physical link issues.

When connectivity is restored on the primary interface, the system will automatically revert to using it as the default gateway, provided that proper interface metrics are defined.

---

## ⚙️ **Default Gateway Priority Handling**

To ensure correct failover and failback behavior, it's crucial to assign a **lower metric value** to your main network interface (e.g., `eth0`) in `/etc/network/interfaces`. The system uses this metric to determine the priority of default routes.

Example configuration:

```bash
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp
    metric 1
```

---

## 🚀 **Running the Ansible Playbook**

To deploy this script and its service using Ansible, make sure to first update your `inventory.ini` file with the correct server information (IP address, SSH user, etc.).

Then run the playbook using:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

---

### 📁 `inventory.ini` Example:

```ini
[network_recovery_targets]
192.168.1.50 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

## 📝 Notes:
- This script is especially useful for headless servers or hypervisors (like Proxmox) that must retain internet access in the event of a primary network failure.
- It relies on `dhclient` to acquire IP addresses and gateway settings for secondary interfaces.
- The systemd timer runs the script periodically or on boot, depending on your configuration.
