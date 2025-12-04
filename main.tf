# ------------------------------------------------------------------------------
# LOCAL VALUES
# ------------------------------------------------------------------------------

locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "terraform"
      Module    = "terraform-aws-secrets-manager"
    }
  )

  # Build full secret names with optional prefix
  secret_names = {
    for k, v in var.secrets : k => var.name_prefix != "" ? "${var.name_prefix}/${k}" : k
  }

  # Secrets with ignore_changes = true (managed outside Terraform after creation)
  secrets_ignore_changes = {
    for k, v in var.secrets : k => v if v.ignore_changes && v.initial_value != null
  }

  # Secrets with ignore_changes = false (fully managed by Terraform)
  secrets_managed = {
    for k, v in var.secrets : k => v if !v.ignore_changes && v.initial_value != null
  }
}

# ------------------------------------------------------------------------------
# SECRETS
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name        = local.secret_names[each.key]
  description = each.value.description
  kms_key_id  = each.value.kms_key_id

  recovery_window_in_days = each.value.recovery_days

  tags = merge(
    local.common_tags,
    {
      Name = local.secret_names[each.key]
    }
  )
}

# ------------------------------------------------------------------------------
# SECRET VERSIONS (with ignore_changes - for secrets managed outside Terraform)
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret_version" "ignore_changes" {
  for_each = local.secrets_ignore_changes

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value.initial_value

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ------------------------------------------------------------------------------
# SECRET VERSIONS (fully managed by Terraform)
# ------------------------------------------------------------------------------

resource "aws_secretsmanager_secret_version" "managed" {
  for_each = local.secrets_managed

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value.initial_value
}
