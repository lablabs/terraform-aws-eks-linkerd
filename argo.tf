locals {
  control_plane_argo_application_metadata = {
    "labels" : try(var.control_plane_argo_metadata.labels, {}),
    "annotations" : try(var.control_plane_argo_metadata.annotations, {}),
    "finalizers" : try(var.control_plane_argo_metadata.finalizers, [])
  }
  control_plane_argo_application_values = {
    "project" : var.argo_project
    "source" : {
      "repoURL" : var.helm_repo_url
      "chart" : var.control_plane_helm_chart_name
      "targetRevision" : var.control_plane_helm_chart_version
      "helm" : merge(
        {
          "releaseName" : var.control_plane_helm_release_name
          "values" : var.enabled ? data.utils_deep_merge_yaml.control_plane_values[0].output : ""
          "skipCrds" : true # CRDs are installed in a separate ArgoCD Application
        },
        length(var.control_plane_settings) > 0 ? {
          "parameters" : [for k, v in var.control_plane_settings : tomap({ "forceString" : true, "name" : k, "value" : v })]
        } : {}
      )
    }
    "destination" : {
      "server" : var.argo_destination_server
      "namespace" : var.namespace
    }
    "syncPolicy" : var.control_plane_argo_sync_policy
    "info" : var.argo_info
  }
}

resource "kubernetes_manifest" "control_plane_argo_application" {
  count = var.enabled && var.argo_enabled && !var.argo_helm_enabled ? 1 : 0
  manifest = {
    "apiVersion" = var.argo_apiversion
    "kind"       = "Application"
    "metadata" = merge(
      local.control_plane_argo_application_metadata,
      { "name" = var.control_plane_helm_release_name },
      { "namespace" = var.argo_namespace },
    )
    "spec" = merge(
      local.control_plane_argo_application_values,
      var.control_plane_argo_spec
    )
  }
  computed_fields = var.control_plane_argo_kubernetes_manifest_computed_fields

  field_manager {
    name            = var.control_plane_argo_kubernetes_manifest_field_manager_name
    force_conflicts = var.control_plane_argo_kubernetes_manifest_field_manager_force_conflicts
  }

  wait {
    fields = var.control_plane_argo_kubernetes_manifest_wait_fields
  }

  depends_on = [
    kubernetes_manifest.crds_argo_application
  ]
}
