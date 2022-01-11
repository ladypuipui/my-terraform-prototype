TERRAFORM := aws-vault exec $(PROFILE) -- terraform

.PHONY: init
init:
	$(TERRAFORM) init

.PHONY: plan
plan:
	$(TERRAFORM) plan

.PHONY: apply
apply:
	$(TERRAFORM) apply
