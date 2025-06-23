#!/bin/bash
# Script de prueba de conectividad entre contenedores Docker Compose

set -e

echo "== Ping desde proxy a CMS1 (WordPress) =="
docker compose exec proxy-nginx ping -c 2 cms1-wordpress

echo "== Ping desde proxy a CMS2 (Joomla) =="
docker compose exec proxy-nginx ping -c 2 cms2-joomla

echo "== Ping desde proxy a la base de datos (cms-db, debe FALLAR) =="
docker compose exec proxy-nginx ping -c 2 cms-db || echo "(Esperado: sin acceso)"

echo "== Ping desde CMS1 a CMS2 =="
docker compose exec cms1-wordpress ping -c 2 cms2-joomla

echo "== Ping desde CMS1 a la base de datos =="
docker compose exec cms1-wordpress ping -c 2 cms-db

echo "== Ping desde CMS2 a la base de datos =="
docker compose exec cms2-joomla ping -c 2 cms-db

echo "== Probar conexión MySQL desde CMS2 (Joomla) =="
docker compose exec cms2-joomla apt update && \
  docker compose exec cms2-joomla apt install -y default-mysql-client && \
  docker compose exec cms2-joomla mysql -h cms-db -u joomla_user -pjoomla_pass -e 'SHOW DATABASES;'

echo "== Probar conexión MySQL desde CMS1 (WordPress) =="
docker compose exec cms1-wordpress apt update && \
  docker compose exec cms1-wordpress apt install -y default-mysql-client && \
  docker compose exec cms1-wordpress mysql -h cms-db -u wp_user -pwp_pass -e 'SHOW DATABASES;'

echo "== Pruebas finalizadas =="
