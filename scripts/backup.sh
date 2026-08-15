#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"

docker compose exec -T db pg_dump -U "${POSTGRES_USER:-appuser}" "${POSTGRES_DB:-rando}" > "$BACKUP_DIR/rando_$TIMESTAMP.sql"

# Rotation : supprime les sauvegardes de plus de 7 jours
find "$BACKUP_DIR" -name "rando_*.sql" -mtime +7 -delete

echo "Sauvegarde créée : $BACKUP_DIR/rando_$TIMESTAMP.sql"