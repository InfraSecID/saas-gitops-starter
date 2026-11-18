# infra/modules/cluster/variables.tf — Variabel modul EKS Cluster
variable "cluster_name" {
  description = "Nama cluster EKS"
  type        = string
}

variable "cluster_role_type" {
  description = "Peran cluster: control-plane atau data-plane"
  type        = string
}

variable "kubernetes_version" {
  description = "Versi Kubernetes EKS"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block VPC cluster"
  type        = string
}

variable "environment" {
  description = "Nama environment (production/staging/dev)"
  type        = string
}

variable "node_min_size" {
  description = "Jumlah minimum worker node pada managed node group"
  type        = number
}

variable "node_max_size" {
  description = "Jumlah maksimum worker node pada managed node group"
  type        = number
}

variable "node_instance_type" {
  description = "Tipe instance EC2 untuk worker node"
  type        = string
}
