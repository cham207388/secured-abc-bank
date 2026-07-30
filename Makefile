.DEFAULT_GOAL := help

API_DIR := securedbank-api
UI_DIR := securedbank-ui
GRADLE := ./gradlew
NPM := npm
NG := ng
COMPOSE := docker compose
TOFU ?= tofu
TF_DIR ?= infra
TF_ARGS ?=

# Keep these aligned with securedbank-api/compose.yml.
export DATABASE_HOST ?= localhost
export DATABASE_PORT ?= 5434
export DATABASE_NAME ?= abcbank
export SPRING_DATASOURCE_USERNAME ?= postgres
export SPRING_DATASOURCE_PASSWORD ?= postgres

# Keycloak / OpenTofu local defaults (override via TF_VAR_* or infra/terraform.tfvars).
export TF_VAR_keycloak_url ?= http://localhost:8180
export TF_VAR_realm ?= securedbankdev
export TF_VAR_client_id ?= securedbank-api
export TF_VAR_client_secret ?= replace-with-a-long-random-secret
export TF_VAR_keycloak_admin_password ?= admin

# Optional local overrides (not committed).
-include infra/.env

.PHONY: help install db-up db-down db-logs install-api install-ui start-ui dev api ui \
	build build-api build-ui test test-api test-ui \
	clean clean-api clean-ui tf-init tf-plan tf-validate tf-apply tf-destroy test-client

help: ## Show the available commands
	@awk 'BEGIN {FS = ":.*## "; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

db-up: ## Start the PostgreSQL development database
	$(COMPOSE) -f $(API_DIR)/compose.yml up -d

db-down: ## Stop the PostgreSQL development database
	$(COMPOSE) -f $(API_DIR)/compose.yml down

db-logs: ## Follow PostgreSQL logs
	$(COMPOSE) -f $(API_DIR)/compose.yml logs -f postgres

install: install-api install-ui ## Install/prepare backend and frontend dependencies

install-api: ## Download the Gradle distribution and backend dependencies
	cd $(API_DIR) && $(GRADLE) dependencies

install-ui: ## Install exact frontend dependencies from package-lock.json
	cd $(UI_DIR) && $(NPM) install

start-ui: ## Start the Angular UI
	cd $(UI_DIR) && $(NG) serve --open

dev: ## Start PostgreSQL, Spring Boot, and Angular together
	@$(MAKE) db-up
	@$(MAKE) api & api_pid=$$!; \
		$(MAKE) ui & ui_pid=$$!; \
		trap 'kill $$api_pid $$ui_pid 2>/dev/null || true' INT TERM EXIT; \
		wait

api: ## Run the Spring Boot API at http://localhost:8080
	cd $(API_DIR) && $(GRADLE) bootRun

ui: ## Run the Angular UI at http://localhost:4200
	cd $(UI_DIR) && $(NPM) start

build: build-api build-ui ## Build backend and frontend production artifacts

build-api: db-up ## Build the Spring Boot application
	cd $(API_DIR) && $(GRADLE) build

build-ui: ## Build the Angular production bundle
	cd $(UI_DIR) && $(NPM) run build

test: test-api test-ui ## Run backend and frontend unit tests

test-api: db-up ## Run Spring Boot tests
	cd $(API_DIR) && $(GRADLE) test

test-ui: ## Run Angular tests once in headless Chrome
	cd $(UI_DIR) && $(NPM) test -- --watch=false --browsers=ChromeHeadless

clean: clean-api clean-ui ## Remove generated backend and frontend build output

clean-api: ## Remove Gradle build output
	cd $(API_DIR) && $(GRADLE) clean

clean-ui: ## Remove Angular build output
	cd $(UI_DIR) && $(NPM) run ng -- cache clean
	find $(UI_DIR)/dist -mindepth 1 -delete 2>/dev/null || true

tf-init:
	$(TOFU) -chdir=$(TF_DIR) init $(TF_ARGS) -upgrade

tf-plan:
	$(TOFU) -chdir=$(TF_DIR) plan $(TF_ARGS)

tf-validate:
	$(TOFU) -chdir=$(TF_DIR) validate $(TF_ARGS)

tf-fmt:
	$(TOFU) -chdir=$(TF_DIR) fmt $(TF_ARGS)

tf-apply:
	$(TOFU) -chdir=$(TF_DIR) apply $(TF_ARGS) --auto-approve

tf-outputs:
	$(TOFU) -chdir=$(TF_DIR) output $(TF_ARGS)

tf-start: tf-init tf-plan tf-validate tf-fmt tf-apply

tf-destroy:
	$(TOFU) -chdir=$(TF_DIR) destroy $(TF_ARGS) --auto-approve

test-client: ## Request a Keycloak client_credentials token
	@curl --fail-with-body --silent --show-error \
		--request POST \
		--url "$${TF_VAR_keycloak_url%/}/realms/$${TF_VAR_realm}/protocol/openid-connect/token" \
		--header 'Content-Type: application/x-www-form-urlencoded' \
		--data 'grant_type=client_credentials' \
		--data-urlencode "client_id=$${TF_VAR_client_id}" \
		--data-urlencode "client_secret=$${TF_VAR_client_secret}"; \
	printf '\n'
