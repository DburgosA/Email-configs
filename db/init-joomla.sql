-- Crear usuario y base de datos para Joomla
CREATE DATABASE IF NOT EXISTS joomla_db;
CREATE USER IF NOT EXISTS 'joomla_user'@'%' IDENTIFIED BY 'joomla_pass';
GRANT ALL PRIVILEGES ON joomla_db.* TO 'joomla_user'@'%';
FLUSH PRIVILEGES;
