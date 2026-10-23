resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-24.04-base.qcow2"
  pool   = "homelab-vms"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}
resource "libvirt_volume" "vm_disk" {
  for_each       = var.nodes
  name           = "${each.key}-disk.qcow2"
  pool           = "homelab-vms"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = each.value.disk_gb * 1073741824
  format         = "qcow2"
}
resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = var.nodes
  name     = "${each.key}-cloudinit.iso"
  pool     = "homelab-vms"

  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname       = each.key
    ssh_public_key = file(var.ssh_public_key_path)
  })
}
resource "libvirt_domain" "vm" {
  for_each = var.nodes
  name     = each.key
  memory   = each.value.ram_mb
  vcpu     = each.value.cpu

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  network_interface {
    network_name = "host-bridge"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}
