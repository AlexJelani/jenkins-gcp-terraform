variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "credentials_file" {
  type        = string
  description = "Path to service account key file"
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "GCP region"
}

variable "zone" {
  type        = string
  default     = "europe-west1-c"
  description = "GCP zone"
}
