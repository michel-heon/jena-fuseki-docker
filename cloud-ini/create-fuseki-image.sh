#!/bin/bash
set -e  # Arrêter en cas d'erreur

# === Variables ===
source ./00-env.sh

# === Étape 1: Créer le groupe de ressources ===
echo "📁 Création du groupe de ressources..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# === Étape 2: Créer la VM avec cloud-init ===
echo "🖥️ Création de la VM avec cloud-init..."
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --image "$OS_IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  --authentication-type password \
  --custom-data "$CLOUD_INIT_FILE" \
  --security-type Standard \
  --output none

# === Étape 3: Ouvrir le port 3030 ===
echo "🌐 Ouverture du port 3030 pour Fuseki..."
az vm open-port --port 3030 --resource-group "$RESOURCE_GROUP" --name "$VM_NAME"

# === Optionnel : Activer les diagnostics de démarrage ===
STORAGE_ACCOUNT="fusekistorage$RANDOM"
echo "📦 Création du compte de stockage pour les diagnostics..."
az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku Standard_LRS
echo "🔍 Activation des diagnostics de démarrage..."
az vm boot-diagnostics enable --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --storage "https://${STORAGE_ACCOUNT}.blob.core.windows.net/"

# === Étape 4: Pause pour cloud-init ===
echo "⏳ Attente de 2 minutes pour la configuration cloud-init..."
sleep 120

# === Étape 5: Vérification de l’accès public ===
PUBLIC_IP=$(az vm show --show-details \
  --name "$VM_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "publicIps" -o tsv)
echo "🌍 Fuseki devrait être accessible à : http://$PUBLIC_IP:3030"

# === Étape 6: Nettoyage de cloud-init pendant que la VM est en cours d'exécution ===
echo "🧹 Nettoyage de l'état cloud-init..."
az vm run-command invoke --command-id RunShellScript --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --scripts "sudo cloud-init clean"

# === Étape 7: Désallocation et généralisation ===
echo "🧊 Désallocation de la VM..."
az vm deallocate --resource-group "$RESOURCE_GROUP" --name "$VM_NAME"
echo "⏳ Attente de la désallocation complète..."
az vm wait --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --custom "instanceView.statuses[?code=='PowerState/deallocated']"

echo "🧼 Généralisation de la VM..."
az vm generalize --resource-group "$RESOURCE_GROUP" --name "$VM_NAME"

# === Étape 8: Création de l’image ===
echo "💿 Création de l'image à partir de la VM généralisée..."
az image create --resource-group "$RESOURCE_GROUP" --name "$IMAGE_NAME" --source "$VM_NAME"  --hyper-v-generation V2

echo "✅ Image '$IMAGE_NAME' créée avec succès dans le groupe '$RESOURCE_GROUP'."
