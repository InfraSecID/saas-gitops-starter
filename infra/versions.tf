# infra/versions.tf — Konfigurasi versi Terraform, provider, dan remote backend S3
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }

  # Remote backend terenkripsi dengan state locking di DynamoDB
  backend "s3" {
    bucket         = "__TF_STATE_BUCKET__"
    key            = "saas-gitops-starter/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "__TF_LOCK_TABLE__"
  }
}
