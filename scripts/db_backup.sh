#!/bin/bash

BACKUP_DIR="/var/backups/db"
DATE=$(date '+%Y%m%d')
BACKUP_FILE="${BACKUP_DIR}/db_backup_${DATE}.sql.gz"

CONTAINER="devops-db"
DB_NAME="devopsdb"
DB_USER="devops"
DB_PASSWORD="devopspass"

mkdir -p "$BACKUP_DIR"

echo "Starting database backup..."

docker exec \
    -e PGPASSWORD="$DB_PASSWORD" \
    "$CONTAINER" \
    pg_dump \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup successful:"
    echo "$BACKUP_FILE"
else
    echo "[ERROR] Database backup failed"
    exit 1
fi

find "$BACKUP_DIR" \
    -type f \
    -name "db_backup_*.sql.gz" \
    -mtime +7 \
    -delete
