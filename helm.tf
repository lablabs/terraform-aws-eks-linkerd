resource "helm_release" "crds" {
  count            = var.enabled && !var.argo_enabled ? 1 : 0
  chart            = var.crds_helm_chart_name
  create_namespace = var.helm_create_namespace
  namespace        = var.namespace
  name             = var.crds_helm_release_name
  version          = var.crds_helm_chart_version
  repository       = var.helm_repo_url

  repository_key_file        = var.helm_repo_key_file
  repository_cert_file       = var.helm_repo_cert_file
  repository_ca_file         = var.helm_repo_ca_file
  repository_username        = var.helm_repo_username
  repository_password        = var.helm_repo_password
  devel                      = var.crds_helm_devel
  verify                     = var.crds_helm_package_verify
  keyring                    = var.crds_helm_keyring
  timeout                    = var.crds_helm_timeout
  disable_webhooks           = var.crds_helm_disable_webhooks
  reset_values               = var.crds_helm_reset_values
  reuse_values               = var.crds_helm_reuse_values
  force_update               = var.crds_helm_force_update
  recreate_pods              = var.crds_helm_recreate_pods
  cleanup_on_fail            = var.crds_helm_cleanup_on_fail
  max_history                = var.crds_helm_release_max_history
  atomic                     = var.crds_helm_atomic
  wait                       = var.crds_helm_wait
  wait_for_jobs              = var.crds_helm_wait_for_jobs
  skip_crds                  = var.crds_helm_skip_crds
  render_subchart_notes      = var.crds_helm_render_subchart_notes
  disable_openapi_validation = var.crds_helm_disable_openapi_validation
  dependency_update          = var.crds_helm_dependency_update
  replace                    = var.crds_helm_replace
  description                = var.crds_helm_description
  lint                       = var.crds_helm_lint

  values = [
    data.utils_deep_merge_yaml.crds_values[0].output
  ]

  dynamic "set" {
    for_each = var.crds_settings
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set_sensitive" {
    for_each = var.crds_helm_set_sensitive
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }

  dynamic "postrender" {
    for_each = var.crds_helm_postrender
    content {
      binary_path = postrender.value
    }
  }
}

resource "time_sleep" "wait_for_crds" {
  count = var.enabled && !var.argo_enabled ? 1 : 0

  create_duration = var.crds_helm_wait_for_crds_duration

  depends_on = [
    helm_release.crds
  ]
}

resource "helm_release" "control_plane" {
  count            = var.enabled && !var.argo_enabled ? 1 : 0
  chart            = var.control_plane_helm_chart_name
  create_namespace = var.helm_create_namespace
  namespace        = var.namespace
  name             = var.control_plane_helm_release_name
  version          = var.control_plane_helm_chart_version
  repository       = var.helm_repo_url

  repository_key_file        = var.helm_repo_key_file
  repository_cert_file       = var.helm_repo_cert_file
  repository_ca_file         = var.helm_repo_ca_file
  repository_username        = var.helm_repo_username
  repository_password        = var.helm_repo_password
  devel                      = var.control_plane_helm_devel
  verify                     = var.control_plane_helm_package_verify
  keyring                    = var.control_plane_helm_keyring
  timeout                    = var.control_plane_helm_timeout
  disable_webhooks           = var.control_plane_helm_disable_webhooks
  reset_values               = var.control_plane_helm_reset_values
  reuse_values               = var.control_plane_helm_reuse_values
  force_update               = var.control_plane_helm_force_update
  recreate_pods              = var.control_plane_helm_recreate_pods
  cleanup_on_fail            = var.control_plane_helm_cleanup_on_fail
  max_history                = var.control_plane_helm_release_max_history
  atomic                     = var.control_plane_helm_atomic
  wait                       = var.control_plane_helm_wait
  wait_for_jobs              = var.control_plane_helm_wait_for_jobs
  skip_crds                  = var.control_plane_helm_skip_crds
  render_subchart_notes      = var.control_plane_helm_render_subchart_notes
  disable_openapi_validation = var.control_plane_helm_disable_openapi_validation
  dependency_update          = var.control_plane_helm_dependency_update
  replace                    = var.control_plane_helm_replace
  description                = var.control_plane_helm_description
  lint                       = var.control_plane_helm_lint

  values = [
    data.utils_deep_merge_yaml.control_plane_values[0].output
  ]

  dynamic "set" {
    for_each = var.control_plane_settings
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set_sensitive" {
    for_each = var.control_plane_helm_set_sensitive
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }

  dynamic "postrender" {
    for_each = var.control_plane_helm_postrender
    content {
      binary_path = postrender.value
    }
  }

  depends_on = [
    time_sleep.wait_for_crds[0]
  ]
}
