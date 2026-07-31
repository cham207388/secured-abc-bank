resource "keycloak_realm" "main" {
  realm        = var.realm
  display_name = var.realm
  enabled      = true

  # Suitable for the local HTTP Keycloak environment.
  # Use "external" or "all" when Keycloak is deployed with HTTPS.
  ssl_required = "none"

  login_with_email_allowed = true
  duplicate_emails_allowed = false
  reset_password_allowed   = true

  # Prevent accidental realm deletion by terraform destroy.
  terraform_deletion_protection = false
}

locals {
  # Shared realm roles used by the M2M service account and human users.
  realm_roles = toset([
    "USER",
    "ADMIN",
  ])
}

# Create USER and ADMIN as realm roles.
resource "keycloak_role" "service_account" {
  for_each = local.realm_roles

  realm_id    = keycloak_realm.main.id
  name        = each.value
  description = "Realm ${each.value} role"
}
