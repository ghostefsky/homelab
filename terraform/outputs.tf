output "vm_macs" {
  description = "MAC-адреса виртуальных машин"
  value = {
    for name, vm in libvirt_domain.vm :
    name => vm.network_interface[0].mac
  }
}
