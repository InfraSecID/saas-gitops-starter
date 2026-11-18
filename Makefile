# Makefile — SaaS Multi-Tenant GitOps Starter Kit
SHELL := /bin/bash
.PHONY: help bootstrap test-backend build-backend validate-kustomize validate-yaml audit clean

help: ## Tampilkan daftar perintah yang tersedia
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

bootstrap: ## Jalankan bootstrap cluster lokal (kind/minikube) + install add-ons
	./bootstrap.sh

test-backend: ## Jalankan unit & integration test pada backend TypeScript
	cd workloads/backend && npm test

build-backend: ## Build Docker image untuk backend multi-stage
	docker build -t ghcr.io/__ORG_NAME__/saas-backend:1.0.0 workloads/backend

validate-kustomize: ## Validasi seluruh manifest Kustomize (base, overlays, platform, local)
	kubectl kustomize workloads/base > /dev/null
	kubectl kustomize workloads/overlays/basic > /dev/null
	kubectl kustomize workloads/overlays/pro > /dev/null
	kubectl kustomize platform-configs > /dev/null
	kubectl kustomize platform-configs/observability > /dev/null
	kubectl kustomize infra/local > /dev/null
	@echo "All Kustomize overlays validated successfully."

 audit: validate-kustomize test-backend ## Jalankan validasi Kustomize dan test backend
	@echo "Self-audit checks passed."

clean: ## Bersihkan artefak build backend
	rm -rf workloads/backend/dist workloads/backend/coverage
