#!/bin/bash
set -e
# Удаляем старый PID, если он остался от аварийного завершения
rm -f /app/tmp/pids/server.pid
# Выполняем команду, переданную в CMD
exec "$@"