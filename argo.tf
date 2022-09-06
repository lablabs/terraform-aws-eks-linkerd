locals {
  crds_argo_application_metadata = {
    "labels" : try(var.crds_argo_metadata.labels, {}),
    "annotations" : try(var.crds_argo_metadata.annotations, {}),
    "finalizers" : try(var.crds_argo_metadata.finalizers, [])
  }
  crds_argo_application_values = {
    "project" : var.argo_project
    "source" : {
      "repoURL" : var.helm_repo_url
      "chart" : var.crds_helm_chart_name
      "targetRevision" : var.crds_helm_chart_version
      "helm" : {
        "releaseName" : var.crds_helm_release_name
        "parameters" : [for k, v in var.crds_settings : tomap({ "forceString" : true, "name" : k, "value" : v })]
        "values" : var.enabled ? data.utils_deep_merge_yaml.crds_values[0].output : ""
      }
    }
    "destination" : {
      "server" : var.argo_destination_server
      "namespace" : var.namespace
    }
    "ignoreDifferences" : [{
      "group" : "apiextensions.k8s.io"
      "kind" : "CustomResourceDefinition"
      "jqPathExpressions" : [
        ".spec.names.shortNames"
      ]
    }]
    "syncPolicy" : var.crds_argo_sync_policy
    "info" : var.argo_info
  }

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
      "helm" : {
        "releaseName" : var.control_plane_helm_release_name
        "parameters" : [for k, v in var.control_plane_settings : tomap({ "forceString" : true, "name" : k, "value" : v })]
        "values" : var.enabled ? data.utils_deep_merge_yaml.control_plane_values[0].output : ""
      }
    }
    "destination" : {
      "server" : var.argo_destination_server
      "namespace" : var.namespace
    }
    "syncPolicy" : var.control_plane_argo_sync_policy
    "info" : var.argo_info
  }
}

data "utils_deep_merge_yaml" "crds_argo_helm_values" {
  count = var.enabled && var.argo_enabled && var.argo_helm_enabled ? 1 : 0
  input = compact([
    yamlencode({
      "apiVersion" : var.argo_apiversion
    }),
    yamlencode({
      "spec" : local.crds_argo_application_values
    }),
    yamlencode({
      "spec" : var.crds_argo_spec
    }),
    yamlencode(
      local.crds_argo_application_metadata
    )
  ])
}

data "utils_deep_merge_yaml" "control_plane_argo_helm_values" {
  count = var.enabled && var.argo_enabled && var.argo_helm_enabled ? 1 : 0
  input = compact([
    yamlencode({
      "apiVersion" : var.argo_apiversion
    }),
    yamlencode({
      "spec" : local.control_plane_argo_application_values
    }),
    yamlencode({
      "spec" : {
        "syncPolicy" : {
          "retry" : {
            "limit" : 5
            "backoff" : {
              "duration" : "30s"
              "factor" : 2
              "maxDuration" : "3m0s"
            }
          }
        }
      }
    }),
    yamlencode({
      "spec" : var.control_plane_argo_spec
    }),
    yamlencode(
      local.control_plane_argo_application_metadata
    )
  ])
}

resource "helm_release" "crds_argo_application" {
  count = var.enabled && var.argo_enabled && var.argo_helm_enabled ? 1 : 0

  chart     = "${path.module}/helm/argocd-application"
  name      = var.crds_helm_release_name
  namespace = var.argo_namespace

  values = [
    data.utils_deep_merge_yaml.crds_argo_helm_values[0].output,
    var.crds_argo_helm_values
  ]
}

resource "helm_release" "control_plane_argo_application" {
  count = var.enabled && var.argo_enabled && var.argo_helm_enabled ? 1 : 0

  chart     = "${path.module}/helm/argocd-application"
  name      = var.control_plane_helm_release_name
  namespace = var.argo_namespace

  values = [
    data.utils_deep_merge_yaml.control_plane_argo_helm_values[0].output,
    var.control_plane_argo_helm_values
  ]
}

resource "kubernetes_manifest" "crds_argo_application" {
  count = var.enabled && var.argo_enabled && !var.argo_helm_enabled ? 1 : 0
  manifest = {
    "apiVersion" = var.argo_apiversion
    "kind"       = "Application"
    "metadata" = merge(
      local.crds_argo_application_metadata,
      { "name" = var.crds_helm_release_name },
      { "namespace" = var.argo_namespace },
    )
    "spec" = merge(
      local.crds_argo_application_values,
      var.crds_argo_spec
    )
  }
  computed_fields = var.crds_argo_kubernetes_manifest_computed_fields

  field_manager {
    name            = var.crds_argo_kubernetes_manifest_field_manager_name
    force_conflicts = var.crds_argo_kubernetes_manifest_field_manager_force_conflicts
  }

  wait {
    fields = merge(
      {
        "status.sync.status"          = "Synced"
        "status.health.status"        = "Healthy"
        "status.operationState.phase" = "Succeeded"
      },
      var.crds_argo_kubernetes_manifest_wait_fields
    )
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
