#!/bin/bash
# this will create Azure resource group
az group create --location eastus --name terraformrg

az storage account create --name terraformstorageaccoun --resource-group terraformrg --location eastus --sku Standard_LRS

az storage container create --name terraform --account-name terraformstorageaccoun
