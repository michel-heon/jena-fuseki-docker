#!/bin/bash

# Liste des namespaces requis pour une offre VM dans Azure Marketplace
required_providers=(
  "Microsoft.Compute"
  "Microsoft.Storage"
  "Microsoft.Network"
  "Microsoft.KeyVault"
  "Microsoft.Resources"
  "Microsoft.PartnerCenterIngestion"
  "Microsoft.Marketplace"
)

ubuntu@ip-10-0-3-37:~/PROJET-AZURE/00-GIT/jena-fu
echo " Checking Azure provider registration status..."

for provider in "${required_providers[@]}"; do
  state=$(az provider show --namespace "$provider" --query "registrationState" -o tsv 2>/dev/null)
  
  if [[ "$state" == "Registered" ]]; then
    echo "$provider is registered"
  else
    echo "$provider is NOT registered"
    echo " Registering $provider..."
    az provider register --namespace "$provider"
  fi
done