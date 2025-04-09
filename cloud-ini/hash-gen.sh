#!/bin/bash
# Définissez votre mot de passe et le nombre d'itérations
password="Cmln1234."
iterations=10

# Génère le premier hash en binaire et le convertit en hexadécimal
hash=$(printf "%s" "$password" | openssl dgst -sha256 -binary | xxd -p -c 256)

# Effectue les itérations de hachage supplémentaires
for ((i=1; i<iterations; i++)); do
    # Convertit le hash hexadécimal en binaire, le hache et le reconvertit en hexadécimal
    echo $i
    hash=$(printf "%s" "$hash" | xxd -r -p | openssl dgst -sha256 -binary | xxd -p -c 256)
done

echo "Hash du mot de passe : "
echo "$hash"
