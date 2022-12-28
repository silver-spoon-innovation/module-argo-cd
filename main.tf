provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster_auth" "ms-sssm" {
  name = var.kubernetes_cluster_id
}

provider "kubernetes" {
	cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
	host                   = var.kubernetes_cluster_endpoint
	token                  = data.aws_eks_cluster_auth.ms-sssm.token
}

provider "helm" {
	kubernetes {
		cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
		host                   = var.kubernetes_cluster_endpoint
		token                  = data.aws_eks_cluster_auth.ms-sssm.token
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

  depends_on = [kubernetes_namespace.ns-argocd]
}