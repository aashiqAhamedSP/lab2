#!/bin/bash
mysqlvmpubip=$(az vm show -d -g lab2rg -n mysqlvm --query publicIps -o tsv)
touch inventory
echo "[remotehosts]" > ./inventory
echo "$mysqlvmpubip ansible_connection=ssh" >> ./inventory
rm ~/.ssh/known_hosts
