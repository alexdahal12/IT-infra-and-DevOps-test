#!/bin/bash

LOG_FILE="/var/log/infra_health.log"
APP_CONTAINER="devops-app"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

WARNING=0

echo "========================================"
echo "Infrastructure Health Check"
echo "Time: $TIMESTAMP"
echo "========================================"

# CPU Usage
CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')
printf "CPU Usage: %.2f%%\n" "$CPU_USAGE"

# RAM Usage
RAM_USAGE=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')
echo "RAM Usage: ${RAM_USAGE}%"

# Disk Usage
DISK_USAGE=$(df / | awk 'NR==2 {gsub("%",""); print $5}')
echo "Root Disk Usage: ${DISK_USAGE}%"

# Docker status
if systemctl is-active --quiet docker; then
    echo "Docker Status: RUNNING"
else
    echo "[WARNING] Docker service is not running"
    echo "[$TIMESTAMP] [WARNING] Docker service is not running" >> "$LOG_FILE"
    WARNING=1
fi

# Application container status
APP_STATUS=$(docker inspect -f '{{.State.Status}}' "$APP_CONTAINER" 2>/dev/null)

if [ "$APP_STATUS" = "running" ]; then
    echo "Application Container: RUNNING"
else
    echo "[WARNING] Application container is stopped"
    echo "[$TIMESTAMP] [WARNING] Application container is stopped" >> "$LOG_FILE"
    WARNING=1
fi

# Disk threshold
if [ "$DISK_USAGE" -gt 85 ]; then
    echo "[WARNING] Root disk usage exceeds 85%"
    echo "[$TIMESTAMP] [WARNING] Root disk usage is ${DISK_USAGE}%" >> "$LOG_FILE"
    WARNING=1
fi

if [ "$WARNING" -eq 0 ]; then
    echo "Health Check Result: OK"
else
    echo "Health Check Result: WARNING"
fi

echo "========================================"
