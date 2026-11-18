# infra/modules/cluster/outputs.tf — Output modul EKS Cluster
output "cluster_id" {
  description = "ID/Nama EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "URL endpoint API server EKS"
  value       = aws_eks_cluster.this.endpoint
}

output "oidc_issuer_url" {
  description = "URL OIDC Issuer dari EKS cluster untuk IRSA"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
