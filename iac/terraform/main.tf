# Ref: https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/master/examples/simple_autopilot_public
# To define that we will use GCP
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.37.0" // Provider version
    }
  }
  required_version = "1.12.1" // Terraform version
}

// The library with methods for creating and
// managing the infrastructure in GCP, this will
// apply to all the resources in the project
provider "google" {
  project     = var.project_id
  region      = var.region
}

// Google Kubernetes Engine
resource "google_container_cluster" "primary" {
  name     = "minhhuy-fsds-gke"
  location = var.zone
  initial_node_count = var.cluster_node_count

  node_config {
    disk_size_gb = 80
    machine_type = "e2-medium"
  }

  // Enabling Autopilot for this cluster
  enable_autopilot = false
}


# // Jenkins
resource "google_compute_instance" "vm_instance" {
  name         = "minhhuyjenkins"
  machine_type = "e2-standard-4"
  zone         = var.zone

  // This instances use ubuntu image
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 50
    }
  }

  // Default network for the instance
  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = var.ssh_keys
  }
}

resource "google_compute_firewall" "default" {
    name =  "allow-jenkins"
    network = "default"
    description = "Create Firewall allow rules for accessing Jenkins"

    allow {
        protocol = "tcp"
        ports = [8081, 50000]
    }

    source_ranges = ["0.0.0.0/0"]
}