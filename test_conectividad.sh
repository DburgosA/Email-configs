#!/bin/bash
# Script de prueba de conectividad entre contenedores Docker Compose

set -e

echo "== Instalando ping en todos los contenedores =="
docker compose exec proxy apt-get update && docker compose exec proxy apt-get install -y iputils-ping

docker compose exec cms1 apt-get update && docker compose exec cms1 apt-get install -y iputils-ping

docker compose exec cms2 apt-get update && docker compose exec cms2 apt-get install -y iputils-ping

docker compose exec db apt-get update && docker compose exec db apt-get install -y iputils-ping

docker compose exec phpmyadmin apt-get update && docker compose exec phpmyadmin apt-get install -y iputils-ping

echo "== Ping desde proxy a CMS1 (WordPress) =="
docker compose exec proxy ping -c 2 cms1

echo "== Ping desde proxy a CMS2 (Joomla) =="
docker compose exec proxy ping -c 2 cms2

echo "== Ping desde proxy a la base de datos (db, debe FALLAR) =="
docker compose exec proxy ping -c 2 db || echo "(Esperado: sin acceso)"

echo "== Ping desde CMS1 a CMS2 =="
docker compose exec cms1 ping -c 2 cms2

echo "== Ping desde CMS1 a la base de datos =="
docker compose exec cms1 ping -c 2 db

echo "== Ping desde CMS2 a la base de datos =="
docker compose exec cms2 ping -c 2 db

echo "== Probar conexión MySQL desde CMS2 (Joomla) =="
docker compose exec cms2 apt-get update && \
  docker compose exec cms2 apt-get install -y default-mysql-client && \
  docker compose exec cms2 mysql -h db -u joomla_user -pjoomla_pass -e 'SHOW DATABASES;'

echo "== Probar conexión MySQL desde CMS1 (WordPress) =="
docker compose exec cms1 apt-get update && \
  docker compose exec cms1 apt-get install -y default-mysql-client && \
  docker compose exec cms1 mysql -h db -u wp_user -pwp_pass -e 'SHOW DATABASES;'

echo "== Pruebas finalizadas =="
