# Proxmox VE Installation & Setup Guide

This guide provides step-by-step instructions for installing and setting up Proxmox Virtual Environment (VE) on your server. Proxmox VE is an open-source server virtualization platform that allows you to manage virtual machines (VMs) and containers efficiently.

---

## Table of Contents
1. [Installation](#installation)
2. [Network Configuration](#network-configuration)
3. [Essential Package Installation](#essential-package-installation)
4. [Creating a Network Bridge](#creating-a-network-bridge)
5. [Additional Tips](#additional-tips)

---

## Installation

### Step 1: Download Proxmox VE ISO
Download the latest version of Proxmox VE from the official website:
- **Download Link:** [Proxmox VE 8.2-1 ISO](https://enterprise.proxmox.com/iso/proxmox-ve_8.2-1.iso)

### Step 2: Create a Bootable USB
Use a tool like **Rufus** to create a bootable USB drive:
- **Rufus Download:** [Rufus Official Website](https://rufus.ie/en/)
- Select the Proxmox ISO file and follow the Rufus instructions to create the bootable USB.

### Step 3: Install Proxmox VE
1. Boot your server from the USB drive.
2. Follow the on-screen instructions to complete the installation.
   - Select the target disk for installation.
   - Set your timezone and keyboard layout.
   - Configure the root password and email address for notifications.

---

## Network Configuration

After installation, configure the network settings to ensure your Proxmox server is accessible.

### Example Configuration:
- **IP Address:** `192.168.50.80`
- **Gateway:** `192.168.50.1`
- **Nameserver:** `192.168.50.1`

To edit the network configuration:
1. Open the network configuration file:
   ```bash
   nano /etc/network/interfaces
   ```
2. Update the file with your network settings:
   ```bash
   auto vmbr0
   iface vmbr0 inet static
       address 192.168.50.80
       netmask 255.255.255.0
       gateway 192.168.50.1
       bridge_ports eth0
       bridge_stp off
       bridge_fd 0
   ```
3. Restart the networking service:
   ```bash
   systemctl restart networking
   ```

## Essential Package Installation

Install essential packages to enhance your Proxmox server's functionality:
   ```bash
   apt update && apt upgrade -y
   apt install -y vim glances tmux net-tools sudo
   ```
- vim: A powerful text editor.

- glances: A system monitoring tool.

- tmux: A terminal multiplexer for managing multiple sessions.

- net-tools: Networking utilities (e.g., ifconfig, netstat).

- sudo: Allows users to run commands with administrative privileges.


## Creating a Network Bridge

A network bridge allows your virtual machines (VMs) to share the host's network connection.

**Steps to Create a Network Bridge:**

   1. Log in to the Proxmox web interface.

   2. Select the node from the sidebar.

   3. Navigate to the Network section.

   4. Click Create and select Linux Bridge.

   5. Configure the bridge:

      - Name: vmbr0 (or any preferred name)

      - IP Address: Set the IP address for the bridge.

      - Bridge Ports: Select the physical network interface (e.g., eth0) to share the network with VMs.

   6. Click OK to save the configuration.


___


## Additional Tips

1. Enable SSH Access

To enable SSH access for remote management:

   ```bash
   systemctl enable ssh
   systemctl start ssh
   ```

2. Backup Your Configuration

Regularly back up your Proxmox configuration files, especially `/etc/network/interfaces` and `/etc/pve/qemu-server/`.

3. Join the Proxmox Community

Join the Proxmox community forums and mailing lists to stay updated and get help:

- Proxmox Forum: [Proxmox Forum](https://forum.proxmox.com/)

4. Monitor Resource Usage
Use tools like **glances** or the Proxmox web interface to monitor CPU, memory, and disk usage.