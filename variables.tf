# IMPORTANT: Add addon specific variables here
variable "crds_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating CRD resources."
}
