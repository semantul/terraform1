terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "k8s-master"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8n9j5udn2212m0dblr"
      size     = 21
    }
  }

  network_interface {
    ip_address = "10.128.0.11"
    subnet_id  = "e9b641h3qponppitdva6"
    nat        = true
    ipv6       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  name = "k8s-worker"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8n9j5udn2212m0dblr"
      size     = 21
    }
  }

  network_interface {
    ip_address = "10.128.0.12"
    subnet_id  = "e9b641h3qponppitdva6"
    nat        = true
    ipv6       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "local_file" "hosts_ini" {
  content = templatefile("hosts.tpl", {
    master = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
    worker = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
  })
  filename   = "./hosts.ini"
  depends_on = [yandex_compute_instance.vm-1, yandex_compute_instance.vm-2]
}


resource "null_resource" "k8s" {
  provisioner "local-exec" {
    command = "sleep 45 && ansible-playbook -l all -i hosts.ini k8s.yaml -b"
  }
  depends_on = [local_file.hosts_ini]
}
