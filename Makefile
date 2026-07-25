.DEFAULT_GOAL := help

API_DIR := securedbank-api
UI_DIR := securedbank-ui
GRADLE := ./gradlew
NPM := npm
NG := ng
COMPOSE := docker compose

# Keep these aligned with securedbank-api/compose.yml.
export DATABASE_HOST ?= localhost
export DATABASE_PORT ?= 5434
export DATABASE_NAME ?= abcbank
export SPRING_DATASOURCE_USERNAME ?= postgres
export SPRING_DATASOURCE_PASSWORD ?= postgres

.PHONY: help install install-api install-ui start-ui dev api ui \
	build build-api build-ui test test-api test-ui \
	clean clean-api clean-ui db-up db-down db-logs

help: ## Show the available commands
	@awk 'BEGIN {FS = ":.*## "; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

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

db-up: ## Start the PostgreSQL development database
	$(COMPOSE) -f $(API_DIR)/compose.yml up -d postgres
	@attempt=0; \
		until $(COMPOSE) -f $(API_DIR)/compose.yml exec -T postgres pg_isready -U $(SPRING_DATASOURCE_USERNAME) -d $(DATABASE_NAME) >/dev/null 2>&1; do \
			attempt=$$((attempt + 1)); \
			if [ $$attempt -ge 30 ]; then echo "PostgreSQL did not become ready"; exit 1; fi; \
			sleep 1; \
		done

db-down: ## Stop the PostgreSQL development database
	$(COMPOSE) -f $(API_DIR)/compose.yml down

db-logs: ## Follow PostgreSQL logs
	$(COMPOSE) -f $(API_DIR)/compose.yml logs -f postgres
