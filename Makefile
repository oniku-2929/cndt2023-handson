
.PHONY: setup
setup:
	cd ./setup/terraform;\
	terraform init;\
	terraform apply -auto-approve;\
	cd ../../ && make bake-ip

.PHONY: clean
clean: clean-ip
	cd ./setup/terraform;\
	terraform init;\
	terraform destroy -auto-approve;

.PHONY: bake-ip
bake-ip:
	cd ./setup/scripts;\
	sudo ./bake_ip.sh

.PHONY: clean-ip
clean-ip:
	cd ./setup/scripts;\
	sudo ./clean_ip.sh

.PHONY: tf-output
tf-output:
	cd ./setup/terraform;\
	terraform output

.PHONY: get-ssh-cmd
get-ssh-cmd:
	cd ./setup/terraform;\
	terraform output -raw ssh_command