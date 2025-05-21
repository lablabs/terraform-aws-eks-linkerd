# IMPORTANT: Add addon specific variables here
variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "crds_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating CRD resources."
}
