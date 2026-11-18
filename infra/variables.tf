# infra/variables.tf — Definisi variabel input dengan placeholder yang jelas
variable "aws_region" {
  description = "Region AWS untuk deployment control plane dan data plane"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Nama environment deployment (production, staging, dev)"
  type        = string
  default     = "production"
}

variable "control_plane_cluster_name" {
  description = "Nama EKS cluster untuk control plane (Argo CD)"
  type        = string
  default     = "__CONTROL_PLANE_CLUSTER_NAME__"
}

variable "data_plane_cluster_name" {
  description = "Nama EKS cluster untuk data plane (workload tenant)"
  type        = string
  default     = "__DATA_PLANE_CLUSTER_NAME__"
}

variable "kubernetes_version" {
  description = "Versi Kubernetes untuk cluster control plane dan data plane"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr_control_plane" {
  description = "CIDR block VPC untuk cluster control plane"
  type        = string
  default     = "10.10.0.0/16"
}

variable "vpc_cidr_data_plane" {
  description = "CIDR block VPC untuk cluster data plane"
  type        = string
  default     = "10.20.0.0/16"
}

variable "gitops_repo_url" {
  description = "URL repositori GitOps yang dipantau oleh Argo CD"
  type        = string
  default     = "https://github.com/__ORG_NAME__/saas-gitops-starter.git"
}

variable "argocd_chart_version" {
  description = "Versi Helm chart argo-cd yang di-pin"
  type        = string
  default     = "6.7.11"
}

variable "eso_chart_version" {
  description = "Versi Helm chart external-secrets yang di-pin"
  type        = string
  default     = "0.9.13"
}

variable "kube_prometheus_stack_version" {
  description = "Versi Helm chart kube-prometheus-stack yang di-pin"
  type        = string
  default     = "57.2.0"
}
