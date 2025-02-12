# Create a VM Template

### **1️ Download the Linux Cloud Image**

SSH into your Proxmox server and download the image:

```
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

```

### **2 Convert and Import the Image**

Convert the image to Proxmox's `qcow2` format and move it to storage:

```
qm create 9000 --name ubuntu-22-cloud --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm template 9000
```

This creates a **Cloud-init template** with VM ID `9000`.