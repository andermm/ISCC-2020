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
for i in `seq 1 8`; do
az vm create \
    --admin-username iscc \
    --resource-group ISCC-2020 \
    --generate-ssh-keys \
    --name A10_ISCC$i \
    --size Standard_A10 \
    --location westus \
    --image UbuntuLTS \
    --verbose

az vm run-command invoke \
	-g ISCC-2020 \
	-n A10_ISCC$i \
	--command-id RunShellScript \
	--scripts "sudo apt update -y && 
	sudo apt upgrade -y && 
	sudo apt autoremove -y && 
	sudo apt install make gfortran openmpi-bin libopenmpi-dev hwloc -y &&
	cd $HOME; git clone --recursive --progress https://github.com/andermm/ISCC-2020.git; 
	chown -R iscc:iscc ISCC-2020; mv ISCC-2020 /home/iscc"
done