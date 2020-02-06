for i in `seq 1 8`; do
az vm create \
	--admin-username iscc \
    --resource-group ISCC-2020 \
    --name ISCC$i \
    --location westus \
    --image UbuntuLTS \
    --verbose \
    --ssh-key-value chave.pub
done