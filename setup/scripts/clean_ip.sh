#!/bin/bash 
pushd $(dirname $0)/../terraform
terraform init
INSTANCE_IP=$(terraform output -raw instance_ip)
BACKUP_ID=`date "+%Y%m%d_%H%M%S"`
sed -i ".$BACKUP_ID" "/$INSTANCE_IP/d" /etc/hosts
popd