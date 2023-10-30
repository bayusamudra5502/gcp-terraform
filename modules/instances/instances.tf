resource "google_compute_instance" "vm_instance" {
  name         = "${var.instance_name}"
  machine_type = "${var.instance_type}"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "${var.network_name}"
    subnetwork = "${var.subnetwork}"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
  EOT

    allow_stopping_for_update = true
  }
