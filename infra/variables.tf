variable "keycloak_url" {
  description = "Base URL of the Keycloak server"
  type        = string
}

variable "keycloak_admin_username" {
  description = "Keycloak administrator username"
  type        = string
  default     = "admin"
}

variable "keycloak_admin_password" {
  description = "Keycloak administrator password"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Client ID of the Secure DBank API"
  type        = string
}

variable "client_secret" {
  description = "Client secret of the Secure DBank API"
  type        = string
  sensitive   = true
}

variable "client_secret_version" {
  description = "Increment this number whenever client_secret is rotated"
  type        = number
  default     = 1
}

variable "realm" {
  description = "Realm name"
  type        = string
}