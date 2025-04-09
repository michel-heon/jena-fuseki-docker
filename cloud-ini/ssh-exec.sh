#!/bin/bash
set -e  # Arrêter en cas d'erreur

# === Variables ===
source ./00-env.sh

PUBLIC_IP=$(az vm show --show-details \
  --name "$VM_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "publicIps" -o tsv)
  
ssh -i ~/.ssh/id_ed25519.pub azureuser@$PUBLIC_IP