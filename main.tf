terraform {
  backend "gcs" {
    bucket = "tf-bucket-788756"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "vm-instances-1" {
  source        = "./modules/instances"
  instance_name = "tf-instance-1"
  instance_type = "e2-standard-2"
  network_name  = module.vpc.network_name
  subnetwork    = "subnet-01" 
}

module "vm-instance-2" {
  source        = "./modules/instances"
  instance_name = "tf-instance-2"
  instance_type = "e2-standard-2"
  network_name  = module.vpc.network_name
  subnetwork    = "subnet-02" 
}

# module "vm-instance-3" {
#   source        = "./modules/instances"
#   instance_name = "tf-instance-31908"
#   instance_type = "e2-standard-2"
# }

module "tf-bucket" {
  source        = "./modules/storage"
  bucket_name   = "tf-bucket-788756"
}

// VPC
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "6.0.0"

  project_id   = "${var.project_id}"
  network_name = "${var.network_name}"
  routing_mode = "GLOBAL"

  subnets = [
      {
          subnet_name           = "subnet-01"
          subnet_ip             = "10.10.10.0/24"
          subnet_region         = "${var.region}"
      },
      {
          subnet_name           = "subnet-02"
          subnet_ip             = "10.10.20.0/24"
          subnet_region         = "${var.region}"
      }
  ]
}

resource "google_compute_firewall" "tf-firewall" {
  name    = "tf-firewall"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}