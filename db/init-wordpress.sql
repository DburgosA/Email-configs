-- Crear usuario y base de datos para WordPress
CREATE DATABASE IF NOT EXISTS wp_db;
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY 'wp_pass';
GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_user'@'%';
FLUSH PRIVILEGES;
