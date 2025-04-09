#!/bin/bash
set -e  # Arrêter en cas d'erreur

# === Variables ===
source ./00-env.sh
NEW_VM_NAME="fuseki-instance"
ADMIN_USER="azureuser"
ADMIN_PASSWORD="Cmln12344321."
VM_SIZE="Standard_B1s"

# === Étape 1: Création de l'instance VM à partir de l'image ===
echo "🖥️ Création de l'instance VM '$NEW_VM_NAME' à partir de l'image '$IMAGE_NAME'..."
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NEW_VM_NAME" \
  --image "$IMAGE_NAME" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  --location "$LOCATION" \
  --output none

# === Étape 2: Ouverture du port 3030 pour Fuseki ===
echo "🌐 Ouverture du port 3030 pour l'accès à Fuseki..."
az vm open-port --port 3030 --resource-group "$RESOURCE_GROUP" --name "$NEW_VM_NAME"

# === Étape 3: Affichage de l'adresse IP publique de l'instance ===
PUBLIC_IP=$(az vm show --show-details \
  --name "$NEW_VM_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "publicIps" -o tsv)
echo "🌍 L'instance est déployée. Fuseki devrait être accessible à : http://$PUBLIC_IP:3030"
