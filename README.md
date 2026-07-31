# Secured Bank

## Frontend

## Backend

Using Spring Boot and Gradle to build the backend.

### Spring Security

The backend is an **OAuth2 Resource Server**. It does not log users in; it validates JWTs sent in the `Authorization: Bearer ...` header and enforces roles.

Keycloak runs locally via Docker Compose (`securedbank-api/compose.yml`, Keycloak 26.7.0 on port 8180). Realm and client configuration is managed with OpenTofu in `infra/`.

```mermaid
flowchart LR
  subgraph keycloak [Keycloak realm securedbankdev]
    M2M[Client securedbank-api]
    AuthCode[Client securedbankclient]
    Pkce[Client securebankclientpublic]
    SA[Service account user]
    Happy[Happy Camper USER]
    John[John Doe USER ADMIN]
    Roles[Realm roles USER ADMIN]
    M2M --> SA
    SA --> Roles
    AuthCode --> Happy
    AuthCode --> John
    Pkce --> Happy
    Pkce --> John
    Happy --> Roles
    John --> Roles
  end

  subgraph spring [Spring Boot API]
    RS[OAuth2 Resource Server]
    Conv[KeycloakRoleConverter]
    AuthZ[hasRole USER ADMIN]
    RS --> Conv --> AuthZ
  end

  M2M -->|client_credentials| Token[token_endpoint]
  AuthCode -->|authorization_code| Token
  Pkce -->|authorization_code_plus_PKCE| Token
  Token -->|Bearer JWT| RS
  JWKS[jwks_uri] -->|public keys| RS
```

#### Keycloak concepts

| Concept | Value in this project | Purpose |
|--------|------------------------|---------|
| **Realm** | `securedbankdev` | Isolated security domain (users, clients, roles, signing keys) |
| **M2M client** | `securedbank-api` | Confidential client for machine-to-machine `client_credentials` access |
| **Auth-code client** | `securedbankclient` | Confidential client for interactive authorization-code login (PKCE off for local testing) |
| **PKCE public client** | `securebankclientpublic` | Public client for SPA-style authorization-code login with PKCE S256 (no client secret) |
| **Service account user** | `service-account-securedbank-api` | Virtual Keycloak user tied to the M2M client |
| **Human users** | `happy@example.com` (USER), `johndoe@example.com` (USER + ADMIN) | Browser login test users; permanent password `Password@123` |
| **Realm roles** | `USER`, `ADMIN` | Assigned to the service account and human users; mapped into JWT `realm_access.roles` |

OpenTofu (`infra/clients.tf`) configures three clients:

**M2M (`securedbank-api`):**

- `service_accounts_enabled = true` — enables the service account user
- `standard_flow_enabled = false` — browser login disabled on this client
- `direct_access_grants_enabled = false` — resource-owner password grant disabled
- `full_scope_allowed = false` — roles must be explicitly mapped into tokens

**Authorization code (`securedbankclient`):**

- `standard_flow_enabled = true` — browser login via `authorization_endpoint`
- `service_accounts_enabled = false` — no service account
- PKCE intentionally unset for learning/testing
- `valid_redirect_uris = ["*"]` — permissive redirect for local experiments

**PKCE public (`securebankclientpublic`):**

- `access_type = PUBLIC` — Client authentication off (no secret)
- `standard_flow_enabled = true` — authorization code grant
- `pkce_code_challenge_method = S256`
- `valid_redirect_uris = ["*"]` — permissive redirect for local experiments

Role flow into Spring Security:

1. OpenTofu creates realm roles (`USER`, `ADMIN`)
2. Roles are assigned to the M2M service account and to human users
3. Role mappers include them in access tokens under `realm_access.roles`
4. `KeycloakRoleConverter` maps `USER` → `ROLE_USER` for `hasRole("USER")` checks

#### OpenID endpoints

All URLs are published from OpenID discovery:

```bash
curl http://localhost:8180/realms/securedbankdev/.well-known/openid-configuration
```

OpenTofu outputs these values (`make tf-outputs`):

| Output | Local URL | Used by |
|--------|-----------|---------|
| [realm](securedbankdev) | `securedbankdev` | Tenant name in every Keycloak URL |
| [client_id](securedbank-api) | `securedbank-api` | M2M token requests; appears in JWT as `azp` / `client_id` |
| [auth_code_client_id](securedbankclient) | `securedbankclient` | Confidential browser authorization-code login (no PKCE) |
| [pkce_client_id](securebankclientpublic) | `securebankclientpublic` | Public browser authorization-code login with PKCE S256 |
| [issuer_uri](http://localhost:8180/realms/securedbankdev) | `http://localhost:8180/realms/securedbankdev` | JWT `iss` claim; Spring can use `issuer-uri` for auto-discovery |
| [jwks_uri](http://localhost:8180/realms/securedbankdev/protocol/openid-connect/certs) | `http://localhost:8180/realms/securedbankdev/protocol/openid-connect/certs` | **Spring Boot today** — public keys for JWT signature validation (`spring.security.oauth2.resourceserver.jwt.jwk-set-uri`) |
| [token_endpoint](http://localhost:8180/realms/securedbankdev/protocol/openid-connect/token) | `http://localhost:8180/realms/securedbankdev/protocol/openid-connect/token` | Token exchange (`client_credentials` or `authorization_code`) |
| [authorization_endpoint](http://localhost:8180/realms/securedbankdev/protocol/openid-connect/auth) | `http://localhost:8180/realms/securedbankdev/protocol/openid-connect/auth` | Browser login redirect for auth-code / PKCE clients |
| [userinfo_endpoint](http://localhost:8180/realms/securedbankdev/protocol/openid-connect/userinfo) | `http://localhost:8180/realms/securedbankdev/protocol/openid-connect/userinfo` | Returns profile claims for human user tokens (returns 403 for service-account tokens) |

#### Spring Boot integration

JWT validation is configured in `securedbank-api/src/main/resources/application.yaml`:

```yaml
spring.security.oauth2.resourceserver.jwt.jwk-set-uri: http://localhost:8180/realms/securedbankdev/protocol/openid-connect/certs
```

Protected routes (non-prod) in `ProjectSecurityNonProdConfig`:

| Endpoint | Access |
|----------|--------|
| `/notices`, `/contact`, `/error`, `/register` | Public |
| `/myAccount`, `/myCards` | `ROLE_USER` |
| `/myBalance` | `ROLE_USER` or `ROLE_ADMIN` |
| `/myLoans`, `/user` | Authenticated |

Validated behavior with a Keycloak M2M token:

| Request | Token | Result |
|---------|-------|--------|
| `GET /notices` | none | 200 (public) |
| `GET /myAccount` | none | 401 (JWT required) |
| `GET /myAccount` | invalid JWT | 401 |
| `GET /myAccount` | valid JWT | Passes auth/roles (400 if required `email` query param is missing) |

#### Commands

```bash
# Start PostgreSQL and Keycloak
make db-up

# Apply Keycloak configuration (set TF_VAR_* env vars first)
make tf-start

# Print OpenTofu outputs
make tf-outputs

# Request a client_credentials token (uses Makefile defaults for local dev)
make test-client

# Call a protected endpoint
curl -H "Authorization: Bearer <access_token>" \
  "http://localhost:8080/myAccount?email=someone@example.com"
```

Required environment variables for OpenTofu (copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars`):

- `TF_VAR_keycloak_url` — default `http://localhost:8180`
- `TF_VAR_realm` — default `securedbankdev`
- `TF_VAR_client_id` — default `securedbank-api`
- `TF_VAR_client_secret` — default `replace-with-a-long-random-secret` (must match `infra/terraform.tfvars`)
- `TF_VAR_auth_code_client_id` — default `securedbankclient`
- `TF_VAR_auth_code_client_secret` — default `replace-with-auth-code-client-secret`
- `TF_VAR_pkce_client_id` — default `securebankclientpublic`
- `TF_VAR_user_password` — default `Password@123`

`make test-client` uses the M2M client defaults automatically. Override any value with `TF_VAR_*` or `infra/.env`.

#### Current state and next steps

- **Three clients are provisioned:** M2M (`securedbank-api`), confidential auth-code without PKCE (`securedbankclient`), and public PKCE S256 (`securebankclientpublic`).
- **Test users** Happy Camper and John Doe exist for browser login flows.
- **Angular is not on Keycloak yet.** The UI still uses cookie/session-based login via `LoginService`, not the `authorization_endpoint`.
- **`/user` with M2M tokens:** `authentication.getName()` resolves to the service account UUID, not an email, so customer lookup returns null.
- **Prod config:** `application-prod.yaml` defaults JWKS to `securedbank-dev` (hyphen); the actual realm is `securedbankdev`. Override with `OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI` or align the default before deploying.

To wire Angular to Keycloak browser login with PKCE:

1. Redirect users to `authorization_endpoint` with `client_id=securebankclientpublic`, `code_challenge`, and `code_challenge_method=S256`
2. Exchange the authorization code at `token_endpoint` with `code_verifier` (no client secret)
3. Send the access token to the Spring API as `Authorization: Bearer ...`


## Database

### PostgreSQL

Using Docker Compose to start the PostgreSQL development database.