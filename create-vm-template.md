# Create VM Template

This guide will walk you through the process of creating a robust and reusable VM template in Proxmox using a cloud image. This template can be used to quickly deploy virtual machines with a consistent configuration.

---

## **1. Prerequisites**

Before starting, ensure you have the following:

- A working Proxmox VE server.
- SSH access to the Proxmox server.
- Sufficient storage space for the cloud image and VM disks.
- Basic familiarity with Proxmox and Linux commands.

---

## **2. Download the Linux Cloud Image**

1. SSH into your Proxmox server.
2. Download the desired cloud image. For this guide, we'll use Ubuntu 22.04 (Jammy Jellyfish):

   ```bash
   wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
   ```

   > **Note**: You can replace the URL with the image of your choice (e.g., CentOS, Debian, etc.). Check the official cloud image repositories for other distributions.

---

## **3. Create a Base VM**

1. Create a new VM with a unique ID (e.g., `9000`) and configure its basic settings:

   ```bash
   qm create 9000 --name ubuntu-22-cloud --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
   ```

   - `9000`: The VM ID. Choose a unique ID for your template.
   - `--name`: The name of the VM.
   - `--memory`: Allocate memory (in MB).
   - `--cores`: Allocate CPU cores.
   - `--net0`: Configure the network interface.

2. Import the downloaded cloud image into the VM:

   ```bash
   qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
   ```

   - `local-lvm`: The storage where the disk will be saved. Replace this with your desired storage.

3. Attach the imported disk to the VM:

   ```bash
   qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
   ```

4. Configure a Cloud-init drive for automated provisioning:

   ```bash
   qm set 9000 --ide2 local-lvm:cloudinit
   ```

5. Set the boot order to use the imported disk:

   ```bash
   qm set 9000 --boot c --bootdisk scsi0
   ```

6. Configure the display settings to use a serial console (useful for headless servers):

   ```bash
   qm set 9000 --serial0 socket --vga serial0
   ```

---

## **4. Configure Cloud-Init**

Cloud-init allows you to automate the initial setup of the VM, such as setting the hostname, user credentials, and network configuration.

1. Set the Cloud-init user and password:

   ```bash
   qm set 9000 --ciuser <username> --cipassword <password>
   ```

   Replace `<username>` and `<password>` with your desired credentials.

2. Configure the SSH key for passwordless login (optional but recommended):

   ```bash
   qm set 9000 --sshkeys ~/.ssh/id_rsa.pub
   ```

   > **Note**: Ensure your SSH public key is located at `~/.ssh/id_rsa.pub`.

3. Set the default IP configuration (optional):

   ```bash
   qm set 9000 --ipconfig0 ip=dhcp
   ```

   For a static IP, use:

   ```bash
   qm set 9000 --ipconfig0 ip=<IP>/<subnet>,gw=<gateway>
   ```

---

## **5. Convert the VM to a Template**

Once the VM is configured, convert it into a template:

```bash
qm template 9000
```

This will mark the VM as a template, making it immutable and ready for cloning.

---

## **6. Deploy VMs from the Template**

To deploy a new VM from the template:

1. Clone the template:

   ```bash
   qm clone 9000 100 --name my-new-vm
   ```

   - `9000`: The template ID.
   - `100`: The new VM ID.
   - `--name`: The name of the new VM.

2. Customize the new VM (if needed):

   - Adjust CPU, memory, or disk size.
   - Update Cloud-init settings (e.g., hostname, IP address).

3. Start the VM:

   ```bash
   qm start 100
   ```

---

## **7. Advanced Customizations**

### **Resize the Disk**

If you need a larger disk for your template:

1. Resize the image before importing:

   ```bash
   qemu-img resize jammy-server-cloudimg-amd64.img +20G
   ```

2. Import the resized image and proceed with the steps above.

### **Add Additional Disks**

To add additional disks to the template:

```bash
qm set 9000 --scsi1 local-lvm:10
```

This adds a 10GB disk to the VM.

### **Install Additional Packages**

If you need additional software pre-installed:

1. Start the VM:

   ```bash
   qm start 9000
   ```

2. SSH into the VM and install the required packages.

3. Stop the VM and convert it back to a template:

   ```bash
   qm stop 9000
   qm template 9000
   ```

---

## **8. Best Practices**

- **Keep Templates Minimal**: Avoid installing unnecessary software to keep templates lightweight and versatile.
- **Regularly Update Templates**: Periodically update your templates with the latest security patches and software versions.
- **Use Version Control**: Maintain multiple versions of templates for different use cases (e.g., `ubuntu-22-cloud-v1`, `ubuntu-22-cloud-v2`).

---

## **9. Troubleshooting**

- **Cloud-init Not Working**: Ensure the Cloud-init drive is properly configured and the VM has network access.
- **Boot Issues**: Verify the boot order and disk configuration.
- **SSH Access Problems**: Double-check the SSH key and Cloud-init user configuration.

---