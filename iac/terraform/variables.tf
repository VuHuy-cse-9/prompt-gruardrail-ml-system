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
