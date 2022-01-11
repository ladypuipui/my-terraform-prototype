MAKE := make
TARGETS := network route53 ssm ec2_web
MIGRATE = "-migrate-state"
REFRESH = "--refresh-only"

define make-r
	@for i in $(TARGETS); do \
		$(MAKE) -w -C $$i $(1) || exit $$?; \
	done
endef

.PHONY: init-r
init-r: ## run "terraform init" recursively
	$(call make-r, init)

.PHONY: plan-r
plan-r: ## run "terraform plan" recursively 
	$(call make-r, plan)

.PHONY: apply-r
apply-r: ## run "terraform apply" recursively 
	$(call make-r, apply)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'