terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws        = ">= 2.23.0"
    kubernetes = ">= 2.5.0"
    helm       = ">= 2.0"
  }
}