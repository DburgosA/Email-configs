# Proyecto: Infraestructura CMS con Docker

## Estructura de Contenedores

- **cms1**: WordPress (PHP, acceso a base de datos)
- **db**: MySQL (usuario y base de datos independientes para cada CMS)
- **cms2**: Joomla (PHP, acceso a base de datos)
- **proxy**: Nginx (proxy inverso con virtual hosts para www.sitio1.test y www.sitio2.test)
- **phpMyAdmin**: Interfaz web para administrar la base de datos MySQL. Acceso en http://localhost:8080 (usuario: root, contraseña: rootpass)

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

## Contenedor Proxy: Nginx

- Imagen: `nginx:1.27`
- Configuración en `proxy/default.conf`:
  - `www.sitio1.test` → WordPress
  - `www.sitio2.test` → Joomla
- Expone el puerto 80 del host

### Ejemplo de hosts en el sistema operativo del host (Windows/Linux):

Agrega estas líneas a tu archivo `hosts` para pruebas locales:

```
127.0.0.1 www.sitio1.test
127.0.0.1 www.sitio2.test
```

Luego accede desde el navegador a http://www.sitio1.test y http://www.sitio2.test

## Cómo iniciar los contenedores

```sh
docker compose up -d
```

## Próximos pasos
- Configurar certificados SSL para HTTPS
- Optimizar configuración de Nginx y PHP

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

## Verificar conectividad interna (entre contenedores)
a) Accede al contenedor de Nginx (proxy):
Deberías ver respuestas exitosas de cada contenedor.

docker compose exec proxy-nginx ping -c 2 cms1-wordpress
docker compose exec proxy-nginx ping -c 2 cms2-joomla
docker compose exec proxy-nginx ping -c 2 cms-db

b) Probar acceso HTTP desde el proxy a los CMS:
Deberías recibir encabezados HTTP 200 OK o 302 Found.

##  Verificar conectividad externa (desde el host)
a) Edita tu archivo hosts (en Windows: hosts):
Agrega estas líneas:

docker compose exec proxy-nginx apt update && apt install -y curl
docker compose exec proxy-nginx curl -I http://cms1-wordpress
docker compose exec proxy-nginx curl -I http://cms2-joomla

b) Abre tu navegador y accede a:
http://www.sitio1.test (debería mostrar WordPress)
http://www.sitio2.test (debería mostrar Joomla)

docker compose exec cms1-wordpress ping cms2-joomla
docker compose exec cms1-wordpress ping cms-db
docker compose exec proxy ping cms1-wordpress
docker compose exec proxy ping cms2-joomla

# Mapa de Redes y Componentes del Servicio

```
                         ┌──────────────────────┐
                         │     RED EXPUESTA     │
                         └──────────────────────┘
                                  │
                                  ▼
                             ┌────────┐
                             │ Proxy │
                             └────────┘
                                  │
                                  ▼
                 ┌────────────────────────────────────┐
                 │     RED ACCESO AL SERVICIO         │
                 └────────────────────────────────────┘
                    │             │              │
                    ▼             ▼              ▼
                ┌──────┐       ┌──────┐       ┌──────┐
                │ CMS1 │       │ CMS2 │       │ CMS3 │
                └──────┘       └──────┘       └──────┘
                    ╲            │           ╱
                     ╲           │          ╱
                      ╲          ▼         ╱
                 ┌────────────────────────────┐
                 │   RED EXCLUSIVA ACCESO     │
                 └────────────────────────────┘
                                  │
                                  ▼
                              ┌──────┐
                              │  DB  │
                              └──────┘
```

## Redes Docker recomendadas
- **red_expuesta**: Solo el proxy está conectado aquí y expone el puerto 80/443.
- **red_servicio**: Proxy y CMS (CMS1, CMS2, CMS3) están conectados aquí.
- **red_db**: Solo los CMS y la base de datos están conectados aquí. El proxy NO tiene acceso a esta red.

## Ejemplo de definición en docker-compose.yml

```yaml
networks:
  red_expuesta:
  red_servicio:
  red_db:
```

Luego, en cada servicio:
- **proxy**: `networks: [red_expuesta, red_servicio]`
- **cms1, cms2, cms3**: `networks: [red_servicio, red_db]`
- **db**: `networks: [red_db]`

Así se logra el aislamiento y la comunicación según el diagrama.

Error

MySQL ha dicho: Documentación
No se estableció la conexión: los parámetros están incorrectos.
mysqli::real_connect(): php_network_getaddresses: getaddrinfo for cms-db failed: Temporary failure in name resolution
mysqli::real_connect(): (HY000/2002): php_network_getaddresses: getaddrinfo for cms-db failed: Temporary failure in name resolution
phpMyAdmin intentó conectarse con el servidor MySQL, y el servidor rechazó esta conexión. Deberá revisar el host, nombre de usuario y contraseña en config.inc.php y asegurarse que corresponden con la información provista por el administrador del servidor MySQL.
