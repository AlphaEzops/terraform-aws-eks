environment := dev
region := us-east-2


cluster:
	cd ./$(environment)/$(region)/terraform && terraform plan && terraform apply

service:
	cd ./$(environment)/$(region)/services && terraform plan && terraform apply