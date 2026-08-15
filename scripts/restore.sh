#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage : ./scripts/restore.sh chemin/vers/fichier.sql"
    exit 1
fi

BACKUP_FILE="$1"

docker compose exec -T db psql -U "${POSTGRES_USER:-appuser}" -d "${POSTGRES_DB:-rando}" < "$BACKUP_FILE"

echo "Restauration terminée depuis : $BACKUP_FILE"