moved {
  from = helm_release.crds_argo_application
  to   = module.crds.helm_release.argo_application
}

moved {
  from = kubernetes_manifest.crds_argo_application
  to   = module.crds.kubernetes_manifest.this
}

moved {
  from = helm_release.crds
  to   = module.crds.helm_release.this
}

moved {
  from = helm_release.control_plane_argo_application
  to   = module.addon.helm_release.argo_application
}

moved {
  from = kubernetes_manifest.control_plane_argo_application
  to   = module.addon.kubernetes_manifest.this
}

moved {
  from = helm_release.control_plane
  to   = module.addon.helm_release.this
}
