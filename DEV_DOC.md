# Developer Documentation

## Prerequisites

The project requires:

- Docker
- Docker Compose
- Make

The domain `jkorvenp.42.fr` must resolve to the machine running the infrastructure.

The following local configuration must exist before starting the project:

- `srcs/.env`
- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`

Passwords and other secrets must not be committed to Git.

## Project Structure

The infrastructure is defined in:

`srcs/docker-compose.yml`

Each service has its own directory under:

`srcs/requirements/`

The mandatory services are:

- NGINX
- WordPress with PHP-FPM
- MariaDB

Each service is built from its own Dockerfile.

## Building and Starting

From the repository root:

```bash
make
```

The default Makefile target first creates the persistent host directories:

- `/home/jkorvenp/data/mariadb`
- `/home/jkorvenp/data/wordpress`

It then runs Docker Compose with the build option and starts the containers in detached mode.

## Makefile Commands

### `make`

Creates the data directories, builds the images when required and starts the infrastructure.

### `make up`

Creates the data directories if necessary and starts the infrastructure without forcing an image rebuild.

### `make down`

Stops and removes the containers and Compose network while preserving the volumes and host data.

### `make clean`

Runs Docker Compose down with the `-v` option, removing the containers, network and Docker volume objects.

The host data under `/home/jkorvenp/data` is preserved.

### `make fclean`

Runs `clean` and then removes `/home/jkorvenp/data`.

This deletes the persistent WordPress and MariaDB data.

### `make re`

Runs `fclean` followed by `all`.

This completely removes the existing persistent data and rebuilds the infrastructure from a clean state.

## Docker Compose

The Compose configuration defines three services.

### NGINX

NGINX is the only external entry point.

It exposes port 443 and accepts TLSv1.2 and TLSv1.3.

It serves the WordPress files and forwards PHP requests to the WordPress PHP-FPM service.

### WordPress

WordPress runs with PHP-FPM and listens internally on port 9000.

During first initialization, the setup script waits until MariaDB is available, downloads and configures WordPress, creates the administrator and regular WordPress user, and then starts PHP-FPM in the foreground.

### MariaDB

MariaDB listens internally on port 3306.

During first initialization, its setup script creates the WordPress database and database user.

MariaDB then runs in the foreground as the main container process.

## Docker Network

The services communicate through the custom Docker bridge network:

`inception`

The service names are used as hostnames inside the Docker network.

WordPress connects to MariaDB using:

`mariadb:3306`

NGINX forwards PHP requests to:

`wordpress:9000`

Neither WordPress nor MariaDB exposes its service port to the host.

## Persistent Data

Two Docker volumes are used:

- `wordpress_data`
- `mariadb_data`

They use bind-backed storage on the host.

WordPress data is stored at:

`/home/jkorvenp/data/wordpress`

MariaDB data is stored at:

`/home/jkorvenp/data/mariadb`

Because the data is stored outside the containers, removing or recreating containers does not remove the WordPress website or database.

The persistent data is intentionally deleted only by:

```bash
make fclean
```

or:

```bash
make re
```

## Useful Docker Compose Commands

Display the state of the services:

```bash
sudo docker compose -f srcs/docker-compose.yml ps
```

Display the project network:

```bash
sudo docker network inspect inception
```

Display the volumes:

```bash
sudo docker volume ls
```

Inspect the WordPress volume:

```bash
sudo docker volume inspect wordpress_data
```

Inspect the MariaDB volume:

```bash
sudo docker volume inspect mariadb_data
```

## Updating the Infrastructure

After modifying a Dockerfile or configuration that is copied into an image, rebuild and start the infrastructure with:

```bash
make
```

Docker Compose rebuilds the required images and recreates services when necessary.

Configuration changes should be verified after rebuilding to ensure that the affected service is operating as expected.