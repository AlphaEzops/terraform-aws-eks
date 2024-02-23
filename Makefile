include .env
export $(shell sed 's/=.*//' .env)

.PHONY: init

init_services:
	cd $(ENV)/$(REGION)/services && tofu init

init_cluster:
	cd $(ENV)/$(REGION)/terraform && tofu init


