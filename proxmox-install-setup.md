# PROXMOX install & setup

## Installation

1. download proxmox latest version: [https://enterprise.proxmox.com/iso/proxmox-ve_8.2-1.iso](https://enterprise.proxmox.com/iso/proxmox-ve_8.2-1.iso)
2. burn it via [https://rufus.ie/en/](https://rufus.ie/en/) 
3. follow up installation setup

## Setup IP

IP: 192.168.99.80

Gateway: 192.168.99.1

nameserver: 192.168.99.1

## Install packages

```bash
apt update
apt upgrade -y
apt install -y vim glances tmux net-tools sudo
```

## Create network bridge

select on node in side bar

go to netowrk section

select `create` 

select linux network bridge

you can set IP and select bridge port for share netowk with VMs
