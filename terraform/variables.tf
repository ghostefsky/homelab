variable "nodes" {
  description = "Карта виртуальных машин для K8s кластера"
  type = map(object({
    cpu     = number
    ram_mb  = number
    disk_gb = number
  }))
  default = {
    "k8s-master" = {
      cpu     = 2
      ram_mb  = 2048
      disk_gb = 20
    }
    "k8s-worker-1" = {
      cpu     = 2
      ram_mb  = 2048
      disk_gb = 20
    }
    "k8s-worker-2" = {
      cpu     = 2
      ram_mb  = 2048
      disk_gb = 20
    }
  }
}

variable "ssh_public_key_path" {
  description = "Путь к SSH ключу"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
