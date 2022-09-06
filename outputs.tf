output "crds_helm_release_metadata" {
  description = "Helm release attributes"
  value       = try(helm_release.crds[0].metadata, {})
}

output "crds_helm_release_application_metadata" {
  description = "Argo application helm release attributes"
  value       = try(helm_release.crds_argo_application[0].metadata, {})
}

output "crds_kubernetes_application_attributes" {
  description = "Argo kubernetes manifest attributes"
  value       = try(kubernetes_manifest.crds_argo_application, {})
}

output "control_plane_helm_release_metadata" {
  description = "Helm release attributes"
  value       = try(helm_release.control_plane[0].metadata, {})
}

output "control_plane_helm_release_application_metadata" {
  description = "Argo application helm release attributes"
  value       = try(helm_release.control_plane_argo_application[0].metadata, {})
}

output "control_plane_kubernetes_application_attributes" {
  description = "Argo kubernetes manifest attributes"
  value       = try(kubernetes_manifest.control_plane_argo_application, {})
}
