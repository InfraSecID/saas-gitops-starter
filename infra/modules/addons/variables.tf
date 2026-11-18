# infra/modules/addons/variables.tf — Variabel modul Add-ons
variable "control_plane_cluster_id" {
  description = "ID cluster Control Plane tempat Argo CD di-deploy"
  type        = string
}

variable "data_plane_cluster_id" {
  description = "ID cluster Data Plane tempat ESO dan Observability di-deploy"
  type        = string
}

variable "data_plane_oidc_issuer_url" {
  description = "OIDC Issuer URL dari cluster Data Plane untuk IRSA ESO"
  type        = string
}

variable "gitops_repo_url" {
  description = "URL repositori GitOps utama"
  type        = string
}

variable "argocd_chart_version" {
  description = "Versi Helm chart Argo CD"
  type        = string
}

variable "eso_chart_version" {
  description = "Versi Helm chart External Secrets Operator"
  type        = string
}

variable "kube_prometheus_stack_version" {
  description = "Versi Helm chart kube-prometheus-stack"
  type        = string
}
