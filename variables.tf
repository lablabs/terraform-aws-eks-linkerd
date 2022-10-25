variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled"
}

# ================ common variables (required) ================

variable "helm_repo_url" {
  type        = string
  default     = "https://helm.linkerd.io/stable"
  description = "Helm repository"
}

variable "helm_create_namespace" {
  type        = bool
  default     = true
  description = "Create the namespace if it does not yet exist"
}

variable "namespace" {
  type        = string
  default     = "linkerd"
  description = "The K8s namespace in which the linkerd service account has been created"
}

# ================ argo variables (required) ================

variable "argo_namespace" {
  type        = string
  default     = "argo"
  description = "Namespace to deploy ArgoCD application CRD to"
}

variable "argo_enabled" {
  type        = bool
  default     = false
  description = "If set to true, the module will be deployed as ArgoCD application, otherwise it will be deployed as a Helm release"
}

variable "argo_helm_enabled" {
  type        = bool
  default     = false
  description = "If set to true, the ArgoCD Application manifest will be deployed using Kubernetes provider as a Helm release. Otherwise it'll be deployed as a Kubernetes manifest. See Readme for more info"
}

variable "argo_destination_server" {
  type        = string
  default     = "https://kubernetes.default.svc"
  description = "Destination server for ArgoCD Application"
}

variable "argo_project" {
  type        = string
  default     = "default"
  description = "ArgoCD Application project"
}

variable "argo_info" {
  type = list(object({
    name  = string
    value = string
  }))
  default = [{
    "name"  = "terraform"
    "value" = "true"
  }]
  description = "ArgoCD info manifest parameter"
}

variable "argo_apiversion" {
  type        = string
  default     = "argoproj.io/v1alpha1"
  description = "ArgoCD Appliction apiVersion"
}

# ================ helm release variables (required) ================

variable "helm_repo_key_file" {
  type        = string
  default     = ""
  description = "Helm repositories cert key file"
}

variable "helm_repo_cert_file" {
  type        = string
  default     = ""
  description = "Helm repositories cert file"
}

variable "helm_repo_ca_file" {
  type        = string
  default     = ""
  description = "Helm repositories cert file"
}

variable "helm_repo_username" {
  type        = string
  default     = ""
  description = "Username for HTTP basic authentication against the helm repository"
}

variable "helm_repo_password" {
  type        = string
  default     = ""
  description = "Password for HTTP basic authentication against the helm repository"
}
