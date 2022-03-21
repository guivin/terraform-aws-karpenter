variable "namespace" {
  description = "The Kubernetes namespace for Karpenter deployment"
  type        = string
  default     = "karpenter"
}

variable "create_namespace" {
  description = "Boolean to create or not the namespace for Karpenter"
  type        = bool
  default     = true
}

variable "service_account_name" {
  description = "The Service Account name for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "create_service_account" {
  description = "Boolean to create or not the service account"
  type        = bool
  default     = true
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 1
}

variable "set" {
  description = "Value block with custom STRING values to be merged with the values yaml."
  type = list(object({
    name  = string
    value = string
  }))
  default = null
}

variable "set_sensitive" {
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff."
  type = list(object({
    path  = string
    value = string
  }))
  default = null
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "worker_iam_role_name" {
  description = "IAM role name used by the EKS workers"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "helm_chart_version" {
  description = "The Helm chart version for Karpenter"
  type        = string
  default     = "v0.5.3"
}
