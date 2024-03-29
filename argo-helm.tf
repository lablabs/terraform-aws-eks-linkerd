locals {
  control_plane_helm_argo_application_enabled      = var.enabled && var.argo_enabled && var.argo_helm_enabled
  control_plane_helm_argo_application_wait_enabled = local.control_plane_helm_argo_application_enabled && length(keys(var.control_plane_argo_kubernetes_manifest_wait_fields)) > 0
  control_plane_helm_argo_application_values = [
    one(data.utils_deep_merge_yaml.control_plane_argo_helm_values[*].output),
    var.control_plane_argo_helm_values
  ]
}

data "utils_deep_merge_yaml" "control_plane_argo_helm_values" {
  count = local.control_plane_helm_argo_application_enabled ? 1 : 0

  input = compact([
    yamlencode({
      "apiVersion" : var.argo_apiversion
    }),
    yamlencode({
      "spec" : local.control_plane_argo_application_values
    }),
    yamlencode({
      "spec" : var.control_plane_argo_spec
    }),
    yamlencode(
      local.control_plane_argo_application_metadata
    )
  ])
}

resource "helm_release" "control_plane_argo_application" {
  count = local.control_plane_helm_argo_application_enabled ? 1 : 0

  chart     = "${path.module}/helm/argocd-application"
  name      = var.control_plane_helm_release_name
  namespace = var.argo_namespace

  values = local.control_plane_helm_argo_application_values

  depends_on = [
    kubernetes_job.crds_helm_argo_application_wait
  ]
}

resource "kubernetes_role" "control_plane_helm_argo_application_wait" {
  count = local.control_plane_helm_argo_application_wait_enabled ? 1 : 0

  metadata {
    name        = "${var.control_plane_helm_release_name}-argo-application-wait"
    namespace   = var.argo_namespace
    labels      = local.control_plane_argo_application_metadata.labels
    annotations = local.control_plane_argo_application_metadata.annotations
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["applications"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "control_plane_helm_argo_application_wait" {
  count = local.control_plane_helm_argo_application_wait_enabled ? 1 : 0

  metadata {
    name        = "${var.control_plane_helm_release_name}-argo-application-wait"
    namespace   = var.argo_namespace
    labels      = local.control_plane_argo_application_metadata.labels
    annotations = local.control_plane_argo_application_metadata.annotations
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = one(kubernetes_role.control_plane_helm_argo_application_wait[*].metadata[0].name)
  }

  subject {
    kind      = "ServiceAccount"
    name      = one(kubernetes_service_account.control_plane_helm_argo_application_wait[*].metadata[0].name)
    namespace = one(kubernetes_service_account.control_plane_helm_argo_application_wait[*].metadata[0].namespace)
  }
}

resource "kubernetes_service_account" "control_plane_helm_argo_application_wait" {
  count = local.control_plane_helm_argo_application_wait_enabled ? 1 : 0

  metadata {
    name        = "${var.control_plane_helm_release_name}-argo-application-wait"
    namespace   = var.argo_namespace
    labels      = local.control_plane_argo_application_metadata.labels
    annotations = local.control_plane_argo_application_metadata.annotations
  }
}

resource "kubernetes_job" "control_plane_helm_argo_application_wait" {
  count = local.control_plane_helm_argo_application_wait_enabled ? 1 : 0

  metadata {
    generate_name = "${var.control_plane_helm_release_name}-argo-application-wait-"
    namespace     = var.argo_namespace
    labels        = local.control_plane_argo_application_metadata.labels
    annotations   = local.control_plane_argo_application_metadata.annotations
  }

  spec {
    template {
      metadata {
        labels      = local.control_plane_argo_application_metadata.labels
        annotations = local.control_plane_argo_application_metadata.annotations
      }

      spec {
        service_account_name = one(kubernetes_service_account.control_plane_helm_argo_application_wait[*].metadata[0].name)

        dynamic "container" {
          for_each = var.control_plane_argo_kubernetes_manifest_wait_fields

          content {
            name    = "${lower(replace(container.key, ".", "-"))}-${md5(jsonencode(local.control_plane_helm_argo_application_values))}" # md5 suffix is a workaround for https://github.com/hashicorp/terraform-provider-kubernetes/issues/1325
            image   = "bitnami/kubectl:latest"
            command = ["/bin/bash", "-ecx"]
            # Waits for ArgoCD Application to be "Healthy", see https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#wait
            #   i.e. kubectl wait --for=jsonpath='{.status.sync.status}'=Healthy application.argoproj.io <$addon-name>
            args = [
              <<-EOT
              kubectl wait \
                --namespace ${var.argo_namespace} \
                --for=jsonpath='{.${container.key}}'=${container.value} \
                --timeout=${var.argo_helm_wait_timeout} \
                application.argoproj.io ${var.control_plane_helm_release_name}
              EOT
            ]
          }
        }

        node_selector = var.argo_helm_wait_node_selector

        dynamic "toleration" {
          for_each = var.argo_helm_wait_tolerations

          content {
            key      = try(toleration.value.key, null)
            operator = try(toleration.value.operator, null)
            value    = try(toleration.value.value, null)
            effect   = try(toleration.value.effect, null)
          }
        }

        # ArgoCD Application status fields might not be available immediately after creation
        restart_policy = "OnFailure"
      }
    }

    backoff_limit = var.argo_helm_wait_backoff_limit
  }

  wait_for_completion = true

  timeouts {
    create = var.argo_helm_wait_timeout
    update = var.argo_helm_wait_timeout
  }

  depends_on = [
    helm_release.control_plane_argo_application
  ]
}
