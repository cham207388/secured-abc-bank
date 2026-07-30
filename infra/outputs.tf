output "realm" {
  value = keycloak_realm.main.realm
}

output "client_id" {
  value = keycloak_openid_client.main.client_id
}

output "issuer_uri" {
  value = "${trimsuffix(var.keycloak_url, "/")}/realms/${keycloak_realm.main.realm}"
}

output "token_endpoint" {
  value = "${trimsuffix(var.keycloak_url, "/")}/realms/${keycloak_realm.main.realm}/protocol/openid-connect/token"
}

output "authorization_endpoint" {
  value = "${trimsuffix(var.keycloak_url, "/")}/realms/${keycloak_realm.main.realm}/protocol/openid-connect/auth"
}

output "userinfo_endpoint" {
  value = "${trimsuffix(var.keycloak_url, "/")}/realms/${keycloak_realm.main.realm}/protocol/openid-connect/userinfo"
}

output "jwks_uri" {
  value = "${trimsuffix(var.keycloak_url, "/")}/realms/${keycloak_realm.main.realm}/protocol/openid-connect/certs"
}