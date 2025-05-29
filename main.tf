/**
 * # AWS EKS Linkerd Terraform module
 *
 * A Terraform module to deploy the [Linkerd](https://linkerd.io/) on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-linkerd/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-linkerd/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-linkerd/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-linkerd/actions/workflows/pre-commit.yaml)
 */
locals {
  crds = {
    name = "linkerd-crds"

    helm_chart_version    = "1.8.0"
    helm_repo_url         = "https://helm.linkerd.io/stable"
    helm_create_namespace = false # CRDs are cluster-wide resources

    argo_kubernetes_manifest_wait_fields = {
      "status.sync.status"   = "Synced"
      "status.health.status" = "Healthy"
    }
  }

  crds_values = yamlencode({})

  addon = {
    name = "linkerd-control-plane"

    helm_chart_version = "1.16.11"
    helm_repo_url      = "https://helm.linkerd.io/stable"
    helm_skip_crds     = var.crds_enabled # CRDs are installed by the CRDs module, if enabled
  }

  addon_values = yamlencode({})

  addon_depends_on = [
    module.crds
  ]
}
