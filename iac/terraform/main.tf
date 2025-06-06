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

# // Google Compute Engine
resource "google_compute_instance" "vm_instance" {
  name         = "prompt-gruardrail-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  // This instances use ubuntu image
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230727"
    }
  }

  // Default network for the instance
  network_interface {
    network = "default"
    access_config {}
  }
}

// Google Kubernetes Engine
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region

  // Enabling Autopilot for this cluster
  enable_autopilot = false
}
