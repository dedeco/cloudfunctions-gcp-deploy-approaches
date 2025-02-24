variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "us-central1"
}

variable "function_name" {
  description = "The name of the Cloud Function"
  type        = string
  default     = "chuck-norris-jokes"
}
