resource "keycloak_openid_client" "client_type" {
  realm_id  = keycloak_realm.main.id
  client_id = var.client_type_client_id

  name        = var.client_type_client_id
  description = "Machine-to-machine OAuth client for ${var.client_type_client_id}"
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

resource "keycloak_openid_client" "auth_code_type" {
  realm_id  = keycloak_realm.main.id
  client_id = var.auth_code_client_id

  name        = var.auth_code_client_id
  description = "Authorization code OAuth client for ${var.auth_code_client_id}"
  enabled     = true

  access_type = "CONFIDENTIAL"

  # Authorization Code grant for interactive browser login.
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
  service_accounts_enabled     = false

  # PKCE intentionally unset so authorization-code can be tested without it.
  valid_redirect_uris = ["*"]
  web_origins         = ["*"]

  # Only explicitly mapped roles are included in access tokens.
  full_scope_allowed = false

  # Write-only: the secret is sent to Keycloak but not stored in state.
  client_secret_wo         = var.auth_code_client_secret
  client_secret_wo_version = var.auth_code_client_secret_version
}

# Assign USER and ADMIN to the securedbank-api service-account user.
resource "keycloak_openid_client_service_account_realm_role" "service_account" {
  for_each = keycloak_role.service_account

  realm_id                = keycloak_realm.main.id
  service_account_user_id = keycloak_openid_client.client_type.service_account_user_id
  role                    = each.value.name
}

# Permit the explicitly assigned realm roles to appear in the M2M client's token.
resource "keycloak_generic_role_mapper" "service_account" {
  for_each = keycloak_role.service_account

  realm_id  = keycloak_realm.main.id
  client_id = keycloak_openid_client.client_type.id
  role_id   = each.value.id
}

# Permit realm roles to appear in tokens issued by the authorization-code client.
resource "keycloak_generic_role_mapper" "auth_code" {
  for_each = keycloak_role.service_account

  realm_id  = keycloak_realm.main.id
  client_id = keycloak_openid_client.auth_code_type.id
  role_id   = each.value.id
}
