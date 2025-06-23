# Proyecto: Infraestructura CMS con Docker

## Estructura de Contenedores

- **cms1**: WordPress (PHP, acceso a base de datos)
- **db**: MySQL (usuario y base de datos independientes para cada CMS)
- **cms2**: Joomla (PHP, acceso a base de datos)
- **proxy**: (Por crear)

## Red Docker
Se utiliza una red bridge personalizada llamada `cms-net` para la comunicación interna.

## Contenedor CMS1: WordPress

- Imagen: `wordpress:6.5`
- Volumen persistente para datos.
- Conectado a la base de datos `db`.

### Variables de entorno usadas:
- `WORDPRESS_DB_HOST=db:3306`
- `WORDPRESS_DB_USER=wp_user`
- `WORDPRESS_DB_PASSWORD=wp_pass`
- `WORDPRESS_DB_NAME=wp_db`

## Contenedor DB: MySQL

- Imagen: `mysql:8.4`
- Volumen persistente para datos.
- Usuario: `wp_user`, Password: `wp_pass`, Base: `wp_db`
- Root Password: `rootpass`

## Contenedor CMS2: Joomla

- Imagen: `joomla:4.4`
- Volumen persistente para datos.
- Conectado a la base de datos `db` (usuario y base independientes).

### Variables de entorno usadas:
- `JOOMLA_DB_HOST=db:3306`
- `JOOMLA_DB_USER=joomla_user`
- `JOOMLA_DB_PASSWORD=joomla_pass`
- `JOOMLA_DB_NAME=joomla_db`

## Cómo iniciar los contenedores

```sh
docker compose up -d
```

## Próximos pasos
- Crear proxy inverso (Nginx/HAProxy)
- Configurar virtual hosts y resolución de nombres

---

**Credenciales de prueba:**
- MariaDB root: `rootpass`
- MariaDB usuario WordPress: `wp_user` / `wp_pass`
- Base de datos WordPress: `wp_db`

**Credenciales de prueba Joomla:**
- MariaDB usuario Joomla: `joomla_user` / `joomla_pass`
- Base de datos Joomla: `joomla_db`

**Red:** `cms-net` (bridge)

**Versiones:**
- WordPress: 6.5
- Joomla: 4.4
- MySQL: 8.4
- Docker Compose: 3.8