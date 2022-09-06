locals {
  crds_values_default = yamlencode({
    # add default values here
  })
  control_plane_values_default = yamlencode({
    # add default values here
  })
}

data "utils_deep_merge_yaml" "crds_values" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.crds_values_default,
    var.crds_values
  ])
}

data "utils_deep_merge_yaml" "control_plane_values" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.control_plane_values_default,
    var.control_plane_values
  ])
}
