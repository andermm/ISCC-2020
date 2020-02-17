#!/bin/bash

# Create a resource group.
az group create --name A8ISCC --location westus

#Create the master virtual machine from A8 template.
az vm create \
    --admin-username iscc \
    --resource-group A8ISCC \
    --generate-ssh-keys \
    --name A8ISCC1 \
    --size Standard_A8 \
    --location westus \
    --image UbuntuLTS \
    --verbose

az vm run-command invoke \
    -g A8ISCC \
    -n A8ISCC1 \
    --command-id RunShellScript \
    --scripts "sudo apt update -y && 
    sudo apt upgrade -y && 
    sudo apt autoremove -y && 
    sudo apt install make gfortran openmpi-bin libopenmpi-dev hwloc nfs-kernel-server g++ -y &&
    cd $HOME; git clone --recursive --progress https://github.com/andermm/ISCC-2020.git; 
    chown -R iscc:iscc ISCC-2020; mv ISCC-2020 /home/iscc;
    echo '/home/iscc/ISCC-2020 (rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports;
    exportfs -a"

#Create the slaves virtual machines from A8 template.
for i in `seq 5 8`; do
az vm create \
    --admin-username iscc \
    --resource-group A8ISCC \
    --generate-ssh-keys \
    --name A8ISCC$i \
    --size Standard_A8 \
    --location westus \
    --image UbuntuLTS \
    --verbose

az vm run-command invoke \
    -g A8ISCC \
    -n A8ISCC$i \
    --command-id RunShellScript \
    --scripts "sudo apt update -y && 
    sudo apt upgrade -y && 
    sudo apt autoremove -y && 
    sudo apt install make gfortran openmpi-bin libopenmpi-dev hwloc nfs-common g++ -y &&
    sudo mount -t nfs A8ISCC1:/home/iscc /home/iscc;
    echo 'A8ISCC1:/home/iscc /home/iscc' >> /etc/fstab"
done

# Create a resource group.
az group create --name A10ISCC --location westus

#Create the master virtual machine from A10 template.
az vm create \
    --admin-username iscc \
    --resource-group A10ISCC \
    --generate-ssh-keys \
    --name A10ISCC1 \
    --size Standard_A10 \
    --location westus \
    --image UbuntuLTS \
    --verbose

az vm run-command invoke \
    -g A10ISCC \
    -n A10ISCC1 \
    --command-id RunShellScript \
    --scripts "sudo apt update -y && 
    sudo apt upgrade -y && 
    sudo apt autoremove -y && 
    sudo apt install make gfortran openmpi-bin libopenmpi-dev hwloc nfs-kernel-server g++ -y &&
    cd $HOME; git clone --recursive --progress https://github.com/andermm/ISCC-2020.git; 
    chown -R iscc:iscc ISCC-2020; mv ISCC-2020 /home/iscc;
    echo '/home/iscc/ISCC-2020 (rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports;
    exportfs -a"

#Create the slaves virtual machines from A10 template.
for i in `seq 5 8`; do
az vm create \
    --admin-username iscc \
    --resource-group A10ISCC \
    --generate-ssh-keys \
    --name A10ISCC$i \
    --size Standard_A10 \
    --location westus \
    --image UbuntuLTS \
    --verbose

az vm run-command invoke \
    -g A10ISCC \
    -n A10ISCC$i \
    --command-id RunShellScript \
    --scripts "sudo apt update -y && 
    sudo apt upgrade -y && 
    sudo apt autoremove -y && 
    sudo apt install make gfortran openmpi-bin libopenmpi-dev hwloc nfs-common g++ -y &&
    sudo mount -t nfs A10ISCC1:/home/iscc /home/iscc;
    echo 'A10ISCC1:/home/iscc /home/iscc' >> /etc/fstab"
done