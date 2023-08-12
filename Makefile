include .envfile

## ----------------------------------------------------------------------
##  Makefile can be used to streamline the process and make it more efficient.
##  Using a Makefile to automate these tasks, developers can save time and reduce the
##  risk of errors when managing complex infrastructure with Terraform.
## ----------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT - SET ENVIRONMENT
# ----------------------------------------------------------------------------------------------------------------------
set_env:
	@echo "-------------------------\n    SET ENVIRONMENT\n-------------------------"
	@echo "AWS VAULT: $(vault_name)"
	@echo "PROJECT:   $(project)"
	@echo "STAGE:     $(stage)"
	@echo "REGION:    $(region)"
	@echo "----------------------------------------------------------------------\nENVIRONMENT: ALWAYS run 'unset AWS_VAULT' before run 'make set_env'\n----------------------------------------------------------------------"
	@echo "TERRAFORM:   Please run 'make plan' to see the changes"
	@echo "----------------------------------------------------------------------\nTERRAFORM: more info in documentation\n"

	@echo PROJECT_NAME=$(project) > .envfile
	@echo STAGE=$(stage) >> .envfile
	@echo VAULT_NAME=$(vault_name) >> .envfile
	@echo AWS_REGION=$(region) >> .envfile
	@aws-vault exec $(vault_name) --no-session --region=$(region)

# ------------------------------------------------------------------------------
# TERRAFORM - PLAN COMMANDS
# ------------------------------------------------------------------------------
plan: ##            PLAN ALL MODULES
	cd terraform/$(STAGE)/${AWS_REGION} && terraform init  && terraform plan

planfile_json: ##   PLAN ALL MODULES AND GENERATE JSON FILE
	bash scripts/tfplanjson.sh ${STAGE}

#-------------------------------------------------------------------------------
# TERRAFORM - APPLY COMMANDS
#-------------------------------------------------------------------------------
apply:
	cd terraform/$(STAGE)/${AWS_REGION} && terraform init && terraform apply

#-------------------------------------------------------------------------------
# TERRAFORM - DESTROY COMMANDS
#-------------------------------------------------------------------------------
destroy:
	cd terraform/$(STAGE)/${AWS_REGION} && terraform init && terraform destroy

#-------------------------------------------------------------------------------
# TERRAFORM - STATE COMMANDS
#-------------------------------------------------------------------------------
state_list:
	terraform state list cd terraform/$(STAGE)/${AWS_REGION}/$(module)

#-------------------------------------------------------------------------------
# TERRAFORM - CLEAN .TERRAFORM
#-------------------------------------------------------------------------------
tf_clean:
	find ./terraform -type d -name ".terraform" -exec rm -rf {} +
	find ./terraform -type f -name ".terraform.lock.hcl" -exec rm -f {} +

#############
# INFRACOST #
#############
infracostauth:
	infracost auth login
infracost:
	bash scripts/infracost.sh ${STAGE}
# need authentication

help: ##            SHOW MAKEFILE OPTIONS.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)