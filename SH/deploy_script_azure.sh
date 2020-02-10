#!/bin/bash

# Create a resource group.
#az group create --name ISCC-2020 --location westus

#Create 8 virtual machines from A8 template.
#for i in `seq 1 8`; do
#az vm create \
#    --admin-username iscc \
#    --resource-group ISCC-2020 \
#    --name try3 \
#    --size Standard_A8 \
#    --location westus \
#    --image UbuntuLTS \
#    --verbose \
#    --ssh-key-value chave.pub \
#    --generate-ssh-keys
#done

#Create 8 virtual machines from A10 template.
#for i in `seq 12 17`; do
az vm create \
    --admin-username iscc \
    --resource-group ISCC-2020 \
    --generate-ssh-keys \
    --name trylast2 \
    --size Standard_A10 \
    --location westus \
    --image UbuntuLTS \
    --verbose
az vm run-command invoke \
	-g ISCC-2020 \
	-n trylast2 \
	--command-id RunShellScript \
	--scripts "sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt install make gfortran openmpi-bin libopenmpi-dev -y"
#done

