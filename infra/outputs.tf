# infra/outputs.tf — Output infrastruktur untuk integrasi CI/CD dan operasional
output "control_plane_cluster_id" {
  description = "ID cluster Kubernetes Control Plane"
  value       = module.control_plane_cluster.cluster_id
}

output "control_plane_endpoint" {
  description = "Endpoint API Server cluster Control Plane"
  value       = module.control_plane_cluster.cluster_endpoint
}

output "data_plane_cluster_id" {
  description = "ID cluster Kubernetes Data Plane"
  value       = module.data_plane_cluster.cluster_id
}

output "data_plane_endpoint" {
  description = "Endpoint API Server cluster Data Plane"
  value       = module.data_plane_cluster.cluster_endpoint
}

output "eso_irsa_role_arn" {
  description = "IAM Role ARN untuk External Secrets Operator di Data Plane"
  value       = module.platform_addons.eso_irsa_role_arn
}

output "argocd_namespace" {
  description = "Namespace tempat Argo CD terpasang di Control Plane"
  value       = module.platform_addons.argocd_namespace
}
