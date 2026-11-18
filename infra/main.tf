# infra/main.tf — Pemanggilan modul cluster (Control Plane & Data Plane) serta Add-ons
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "saas-gitops-starter"
    }
  }
}

# 1. Cluster Control Plane (tempat Argo CD berjalan terpusat)
module "control_plane_cluster" {
  source             = "./modules/cluster"
  cluster_name       = var.control_plane_cluster_name
  cluster_role_type  = "control-plane"
  kubernetes_version = var.kubernetes_version
  vpc_cidr           = var.vpc_cidr_control_plane
  environment        = var.environment
  node_min_size      = 2
  node_max_size      = 4
  node_instance_type = "t3.medium"
}

# 2. Cluster Data Plane (tempat workload tenant Basic & Pro dijalankan)
module "data_plane_cluster" {
  source             = "./modules/cluster"
  cluster_name       = var.data_plane_cluster_name
  cluster_role_type  = "data-plane"
  kubernetes_version = var.kubernetes_version
  vpc_cidr           = var.vpc_cidr_data_plane
  environment        = var.environment
  node_min_size      = 3
  node_max_size      = 10
  node_instance_type = "t3.large"
}

# 3. Add-ons Platform (Argo CD di Control Plane; ESO & Prometheus/Grafana di Data Plane)
module "platform_addons" {
  source                        = "./modules/addons"
  control_plane_cluster_id      = module.control_plane_cluster.cluster_id
  data_plane_cluster_id         = module.data_plane_cluster.cluster_id
  data_plane_oidc_issuer_url    = module.data_plane_cluster.oidc_issuer_url
  gitops_repo_url               = var.gitops_repo_url
  argocd_chart_version          = var.argocd_chart_version
  eso_chart_version             = var.eso_chart_version
  kube_prometheus_stack_version = var.kube_prometheus_stack_version
}
