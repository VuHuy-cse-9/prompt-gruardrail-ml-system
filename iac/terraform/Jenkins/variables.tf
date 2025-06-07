// Variables to use accross the project
// which can be accessed by var.project_id
variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "tidy-scholar-458913-v7"
}

variable "region" {
  description = "The region the cluster in"
  default     = "asia-southeast1"
}

variable "zone" {
  description = "The zone the compute instance in"
  default     = "asia-southeast1-a"
}

variable "bucket" {
  description = "GCS bucket for MLE course"
  default     = "minhhuy-terraform-demo"
}

variable "cluster_node_count" {
  description = "Number of nodes within the pool"
  default = 3
}

variable "ssh_keys" {
    default = "huyvu2001:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDVQ/FjIVZs8SeLLdqAHef845+wTZYa8dyb6g00VSMkr your_email@example.com"
    description = "Public SSH key, use for access VM instance."
  
}