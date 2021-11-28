#!/bin/bash
export KEY=$(az storage account keys list -g terraformrg -n terraformstorageaccoun --query [0].value -o tsv)
echo $KEY
echo "yes"
