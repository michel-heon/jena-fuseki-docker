#!/bin/bash

# === Valeurs par défaut ===
VM_USER="azureuser"
SSH_KEY="$HOME/.ssh/id_rsa"
LOG_ARCHIVE="fuseki-logs.tar.gz"
LOCAL_OUTPUT_DIR="./fuseki-logs"

# === Lecture des arguments ===
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --ip) VM_IP="$2"; shift ;;
    --user) VM_USER="$2"; shift ;;
    --key) SSH_KEY="$2"; shift ;;
    --outdir) LOCAL_OUTPUT_DIR="$2"; shift ;;
    *) echo "❌ Option inconnue : $1" && exit 1 ;;
  esac
  shift
done

# === Validation ===
if [ -z "$VM_IP" ]; then
  echo "❌ Usage : $0 --ip <VM_IP> [--user <user>] [--key <ssh_key>] [--outdir <dir>]"
  exit 1
fi

REMOTE_SCRIPT="/tmp/extract-fuseki-logs.sh"

# === 1. Préparer le script distant ===
cat << 'EOF' > temp_extract_script.sh
#!/bin/bash
TMPDIR=$(mktemp -d)
LOGDIR="$TMPDIR/fuseki-logs"
mkdir -p "$LOGDIR"

sudo cp /var/log/cloud-init*.log "$LOGDIR/" 2>/dev/null
sudo journalctl -u fuseki.service > "$LOGDIR/fuseki-journal.log" 2>/dev/null
sudo systemctl status fuseki > "$LOGDIR/fuseki-status.log" 2>/dev/null
cp /opt/fuseki/config.ttl "$LOGDIR/config.ttl" 2>/dev/null
cp /opt/fuseki/run/configuration/fuseki-users.rdf "$LOGDIR/fuseki-users.rdf" 2>/dev/null
ls -lR /opt/fuseki > "$LOGDIR/ls-opt-fuseki.log" 2>/dev/null
ls -lR /data/fuseki > "$LOGDIR/ls-data-fuseki.log" 2>/dev/null

tar -czf "$TMPDIR/fuseki-logs.tar.gz" -C "$LOGDIR" .
mv "$TMPDIR/fuseki-logs.tar.gz" /tmp/fuseki-logs.tar.gz
EOF

# === 2. Copier et exécuter sur la VM ===
scp -i "$SSH_KEY" temp_extract_script.sh "$VM_USER@$VM_IP:$REMOTE_SCRIPT"
ssh -i "$SSH_KEY" "$VM_USER@$VM_IP" "chmod +x $REMOTE_SCRIPT && bash $REMOTE_SCRIPT"

# === 3. Télécharger les logs ===
mkdir -p "$LOCAL_OUTPUT_DIR"
scp -i "$SSH_KEY" "$VM_USER@$VM_IP:/tmp/$LOG_ARCHIVE" "$LOCAL_OUTPUT_DIR/"

# === 4. Extraction locale ===
cd "$LOCAL_OUTPUT_DIR" && tar -xzf "$LOG_ARCHIVE" && rm "$LOG_ARCHIVE"
cd -

# === 5. Nettoyage ===
rm temp_extract_script.sh
ssh -i "$SSH_KEY" "$VM_USER@$VM_IP" "rm -f $REMOTE_SCRIPT /tmp/$LOG_ARCHIVE"

echo "✅ Logs extraits dans $LOCAL_OUTPUT_DIR"
