#!/bin/bash

# Charger les variables d'environnement
source ./00-env.sh

# Variables spécifiques
VM_DEPLOY_NAME="fuseki-test-vm"
GALLERY_NAME="fusekiGallery"
IMAGE_DEF="fusekiDefinition"
IMAGE_VERSION="1.0.0"
NSG_NAME="${VM_DEPLOY_NAME}-nsg"

# Chemin complet vers l’image dans la Shared Image Gallery
GALLERY_IMAGE="/subscriptions/$(az account show --query 'id' -o tsv)/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Compute/galleries/${GALLERY_NAME}/images/${IMAGE_DEF}/versions/${IMAGE_VERSION}"

# Création de la VM
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_DEPLOY_NAME" \
  --image "$GALLERY_IMAGE" \
  --admin-username "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  --size "$VM_SIZE" \
  --location "$LOCATION" \
  --generate-ssh-keys \
  --custom-data "$CLOUD_INIT_FILE" \
  --output json

# Récupération du NSG automatiquement créé (ou créer un dédié si requis)
NIC_ID=$(az vm show -g "$RESOURCE_GROUP" -n "$VM_DEPLOY_NAME" --query "networkProfile.networkInterfaces[0].id" -o tsv)
NSG_ID=$(az network nic show --ids "$NIC_ID" --query "networkSecurityGroup.id" -o tsv)

# Ouverture des ports nécessaires : SSH (22), HTTP (80), Fuseki (3030)
for port in 22 80 3030; do
  az network nsg rule create \
    --nsg-name "$(basename $NSG_ID)" \
    --resource-group "$RESOURCE_GROUP" \
    --name "Allow-Port-$port" \
    --priority $((1000 + port)) \
    --direction Inbound \
    --access Allow \
    --protocol Tcp \
    --destination-port-range "$port" \
    --source-address-prefixes "*" \
    --destination-address-prefixes "*" >/dev/null
done

echo "✅ VM '$VM_DEPLOY_NAME' déployée avec les ports 22, 80 et 3030 ouverts."
