terraform {
  required_providers {
    datadog = {
      source = "terraform-providers/datadog"
    }
    google = {
      source = "hashicorp/google"
    }
  }
  required_version = ">= 0.13"
}
