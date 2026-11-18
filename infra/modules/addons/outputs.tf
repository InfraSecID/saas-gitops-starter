# infra/modules/addons/outputs.tf — Output modul Add-ons
output "eso_irsa_role_arn" {
  description = "ARN IAM Role untuk External Secrets Operator"
  value       = aws_iam_role.eso_irsa.arn
}

output "argocd_namespace" {
  description = "Namespace Argo CD di Control Plane"
  value       = helm_release.argocd.namespace
}
