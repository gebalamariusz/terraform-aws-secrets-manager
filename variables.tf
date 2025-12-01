# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "secrets" {
  description = <<-EOT
    Map of secrets to create. The key is the secret name.

    Each secret object supports:
    - description     (optional) - Description of the secret
    - kms_key_id      (optional) - KMS key ID for encryption (uses AWS managed key if not specified)
    - recovery_days   (optional) - Number of days to recover a deleted secret (0-30, default: 30)
    - initial_value   (optional) - Initial value (WARNING: stored in state, use only for non-sensitive defaults)
    - ignore_changes  (optional) - If true, Terraform ignores changes to secret value (default: true)

    NOTE: For security, set actual secret values manually in AWS Console or via CLI after creation.
  EOT
  type = map(object({
    description    = optional(string, "")
    kms_key_id     = optional(string)
    recovery_days  = optional(number, 30)
    initial_value  = optional(string)
    ignore_changes = optional(bool, true)
  }))

  validation {
    condition     = length(var.secrets) > 0
    error_message = "At least one secret must be defined."
  }

  validation {
    condition = alltrue([
      for k, v in var.secrets : v.recovery_days >= 0 && v.recovery_days <= 30
    ])
    error_message = "Recovery days must be between 0 and 30."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for secret names (e.g., 'myapp/prod')"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
