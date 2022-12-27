provider "kubernetes" {
	cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
	host                   = var.kubernetes_cluster_endpoint
	exec {
		api_version = "client.authentication.k8s.io/v1beta1"
		command     = "aws"
		args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
	}
}

provider "helm" {
	kubernetes {
		cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
		host                   = var.kubernetes_cluster_endpoint
		exec {
			api_version = "client.authentication.k8s.io/v1beta1"
			command     = "aws"
			args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
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

  depends_on = [kubernetes_namespace.ns-argocd]
}