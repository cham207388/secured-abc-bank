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

resource "keycloak_openid_client" "client_type" {
  realm_id  = keycloak_realm.main.id
  client_id = var.client_id

  name        = var.client_id
  description = "Machine-to-machine OAuth client for ${var.client_id}"
  enabled     = true

  access_type = "CONFIDENTIAL"

  # Enables the OAuth 2.0 Client Credentials grant.
  service_accounts_enabled = true

  # Disable grants that are not needed by this machine client.
  standard_flow_enabled        = false
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false

  # Only explicitly mapped roles are included in access tokens.
  full_scope_allowed = false

  # Write-only: the secret is sent to Keycloak but not stored in state.
  client_secret_wo         = var.client_secret
  client_secret_wo_version = var.client_secret_version
}

locals {
  service_account_roles = toset([
    "USER",
    "ADMIN",
  ])
}

# Create USER and ADMIN as realm roles.
resource "keycloak_role" "service_account" {
  for_each = local.service_account_roles

  realm_id    = keycloak_realm.main.id
  name        = each.value
  description = "Terraform Test ${each.value} role"
}

# Assign USER and ADMIN to the securedbank-api service-account user.
resource "keycloak_openid_client_service_account_realm_role" "service_account" {
  for_each = keycloak_role.service_account

  realm_id                = keycloak_realm.main.id
  service_account_user_id = keycloak_openid_client.client_type.service_account_user_id
  role                    = each.value.name
}

# Permit the explicitly assigned realm roles to appear in this client's token.
resource "keycloak_generic_role_mapper" "service_account" {
  for_each = keycloak_role.service_account

  realm_id  = keycloak_realm.main.id
  client_id = keycloak_openid_client.client_type.id
  role_id   = each.value.id
}
