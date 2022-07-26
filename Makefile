# ================================================================
# Packer
# ================================================================

.PHONY: packer
packer: ## packer: build the base image -> used as a base for the VMs
	@echo "+ $@"
	@cd packer && \
		packer build template.json

# ================================================================
# Ansible Setup
# ================================================================
.PHONY: allow-ui
allow-ui: ## allow-ui: open nomad & consul ui port on ufw
	@echo "+ $@"
	@cd ansible && \
		ansible-playbook -v ufw_allow.yml

.PHONY: block-ui
block-ui: ## block-ui: close nomad & consul ui port on ufw
	@echo "+ $@"
	@cd ansible && \
		ansible-playbook -v ufw_block.yml

.PHONY: help
help: ## help: list this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | sed 's/^[^:]*://g' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
