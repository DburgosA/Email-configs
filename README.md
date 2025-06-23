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

daniel@daniel-VirtualBox:~/containers$ docker compose exec proxy-nginx apt-get update 
service "proxy-nginx" is not running
daniel@daniel-VirtualBox:~/containers$ docker compose exec proxy apt-get update Get:1 http://deb.debian.org/debian bookworm InRelease [151 kB]
Get:2 http://deb.debian.org/debian bookworm-updates InRelease [55.4 kB]
Get:3 http://deb.debian.org/debian-security bookworm-security InRelease [48.0 kB]
Get:4 http://deb.debian.org/debian bookworm/main amd64 Packages [8793 kB]
Get:5 http://deb.debian.org/debian bookworm-updates/main amd64 Packages [756 B]
Get:6 http://deb.debian.org/debian-security bookworm-security/main amd64 Packages [268 kB]
Fetched 9316 kB in 5s (1753 kB/s)                         
Reading package lists... Done
daniel@daniel-VirtualBox:~/containers$ docker compose exec cms1-wordpress apt-get update
service "cms1-wordpress" is not running
daniel@daniel-VirtualBox:~/containers$ docker compose exec cms1 apt-get update
Get:1 http://deb.debian.org/debian bookworm InRelease [151 kB]
Get:2 http://deb.debian.org/debian bookworm-updates InRelease [55.4 kB]
Get:3 http://deb.debian.org/debian-security bookworm-security InRelease [48.0 kB]
Get:4 http://deb.debian.org/debian bookworm/main amd64 Packages [8793 kB]
Get:5 http://deb.debian.org/debian bookworm-updates/main amd64 Packages [756 B]
Get:6 http://deb.debian.org/debian-security bookworm-security/main amd64 Packages [268 kB]
Fetched 9316 kB in 5s (1961 kB/s)                         
Reading package lists... Done

daniel@daniel-VirtualBox:~/containers$ docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                                     NAMES
78470b792884   nginx:1.27       "/docker-entrypoint.…"   27 minutes ago   Up 27 minutes   0.0.0.0:80->80/tcp, [::]:80->80/tcp       proxy-nginx
024e77dc19bf   wordpress:6.5    "docker-entrypoint.s…"   27 minutes ago   Up 27 minutes   80/tcp                                    cms1-wordpress
ffaa4714253e   joomla:4.4       "/entrypoint.sh apac…"   27 minutes ago   Up 27 minutes   80/tcp                                    cms2-joomla
1678e522bb6d   phpmyadmin:5.2   "/docker-entrypoint.…"   27 minutes ago   Up 27 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   phpmyadmin
0c628ed068b2   mysql:8.4        "docker-entrypoint.s…"   27 minutes ago   Up 27 minutes   3306/tcp, 33060/tcp                       cms-db
daniel@daniel-VirtualBox:~/containers$ 

