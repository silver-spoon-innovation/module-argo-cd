provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
  host                   = var.kubernetes_cluster_endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name, "--profile",var.aws_profile ]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name ,"--profile",var.aws_profile ]
      command     = "aws"
    }
  }
}

resource "kubernetes_namespace" "ns-argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.ns-argocd.metadata.0.name
  create_namespace = false
  timeout          = 3600

  depends_on = [kubernetes_namespace.ns-argocd]
}
