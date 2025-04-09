#!/bin/bash

# Charger les variables d'environnement
source ./00-env.sh

# 1. Créer une Shared Image Gallery (si elle n'existe pas déjà)
az sig create \
  --resource-group "$RESOURCE_GROUP" \
  --gallery-name fusekiGallery \
  --location "$LOCATION"

# 2. Créer une définition d’image dans la galerie
az sig image-definition create \
  --resource-group "$RESOURCE_GROUP" \
  --gallery-name fusekiGallery \
  --gallery-image-definition fusekiDefinition \
  --publisher cotechnoe \
  --offer fuseki-offer \
  --sku fuseki-sku \
  --os-type Linux \
  --os-state Generalized \
  --hyper-v-generation V2 \
  --location "$LOCATION"

# 3. Créer la version de l’image depuis l’image généralisée
az sig image-version create \
  --resource-group "$RESOURCE_GROUP" \
  --gallery-name fusekiGallery \
  --gallery-image-definition fusekiDefinition \
  --gallery-image-version 1.0.0 \
  --managed-image "$IMAGE_NAME" \
  --location "$LOCATION" \
  --replica-count 1 \
  --storage-account-type Standard_LRS
