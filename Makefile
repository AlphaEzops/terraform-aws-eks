include .env
export $(shell sed 's/=.*//' .env)

.PHONY: init_services plan_services apply_services destroy_services

# ==============================================================================
# INFRA SERVICES
# ==============================================================================
init_services:
	cd $(ENV)/$(REGION)/services && tofu init \
	--backend-config="bucket=$(TF_BUCKET)"    \
	--backend-config="key=$(TF_SERVICE_KEY)"  \
	--backend-config="encrypt=true"           \
	--var-file=./terraform.tfvars 

plan_services:
	cd $(ENV)/$(REGION)/services && tofu plan  \
	-out="./tfplan.bin" -input=false \
	-var-file=./terraform.tfvars
	
apply_services:
	cd $(ENV)/$(REGION)/services && tofu apply \
	"./tfplan.bin" -no-color

destroy_services:
	cd $(ENV)/$(REGION)/services && tofu destroy \
	-var-file=./terraform.tfvars

# ==============================================================================
# INFRA BASELINE
# ==============================================================================
init_cluster:
	cd $(ENV)/$(REGION)/terraform && tofu init \
	--backend-config="bucket=$(TF_BUCKET)"     \
	--backend-config="key=$(TF_CLUSTER_KEY)"   \
	--backend-config="encrypt=true"            \
	--var-file=./terraform.tfvars

plan_cluster:
	cd $(ENV)/$(REGION)/terraform && tofu plan \
	-out="./tfplan.bin" -input=false           \
	-var-file=./terraform.tfvars

apply_cluster:
	cd $(ENV)/$(REGION)/terraform && tofu apply \
	"./tfplan.bin" -no-color

destroy_cluster:
	cd $(ENV)/$(REGION)/terraform && tofu destroy \
	-var-file=./terraform.tfvars

