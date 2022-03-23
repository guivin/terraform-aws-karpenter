output "namespace" {
  description = "The Kubernetes namespace where Karpenter is deployed"
  value       = var.namespace
}

output "role_arn" {
  description = "The role ARN used by Karpenter"
  value       = module.iam_assumable_role_karpenter.iam_role_arn
}
