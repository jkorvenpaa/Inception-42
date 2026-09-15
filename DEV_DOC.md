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


## Evaluation Commands

The following commands are useful during the project evaluation.

### Copy the Project to the VM

```bash
scp -P 2222 -r inception jkorvenp@127.0.0.1:/home/jkorvenp/
```

Copies the `inception` directory recursively to the VM through the SSH port forwarding on port 2222.

### Connect to the VM

```bash
ssh -p 2222 jkorvenp@127.0.0.1
```

Opens an SSH connection to the VM through port 2222.

### Check Running Services

```bash
sudo docker compose -f srcs/docker-compose.yml ps
```

Displays the state of the NGINX, WordPress and MariaDB services.

### Check Docker Networks

```bash
sudo docker network ls
```

Lists Docker networks. The `inception` network should be present while the project is running.

### Check HTTPS

```bash
curl -k -I https://jkorvenp.42.fr
```

Checks that the website responds through HTTPS on port 443. The `-k` option accepts the self-signed certificate and `-I` displays the response headers.

### Check That HTTP Is Unavailable

```bash
curl -k -I http://jkorvenp.42.fr
```

Checks that the website is not available through HTTP on port 80.

### Check TLS 1.2

```bash
curl -k -I --tlsv1.2 --tls-max 1.2 https://jkorvenp.42.fr
```

Forces the connection to use TLS 1.2 and verifies that TLS 1.2 is accepted.

### Check That TLS 1.1 Is Rejected

```bash
curl -k -I --tlsv1.1 --tls-max 1.1 https://jkorvenp.42.fr
```

Forces the connection to use TLS 1.1. The connection should fail because NGINX accepts only TLS 1.2 and TLS 1.3.

### Check Docker Volumes

```bash
sudo docker volume ls
```

Lists the Docker volumes. The project should have `wordpress_data` and `mariadb_data`.

### Open WordPress Administration

```text
https://jkorvenp.42.fr/wp-admin
```

Opens the WordPress administration interface in a browser.

### Enter the MariaDB Container

```bash
sudo docker exec -it mariadb sh
```

Opens an interactive shell inside the running MariaDB container.

### Connect to the WordPress Database

From inside the MariaDB container:

```bash
mariadb -u wpuser -p wordpress
```

Connects to the `wordpress` database as the `wpuser` database user and prompts for its password.

### List Databases

From the MariaDB prompt:

```sql
SHOW DATABASES;
```

Displays the available databases.

### Select the WordPress Database

```sql
USE wordpress;
```

Selects the `wordpress` database.

### List WordPress Tables

```sql
SHOW TABLES;
```

Displays the tables stored in the WordPress database.

### Check WordPress Comments

```sql
SELECT * FROM wp_comments;
```

Displays the rows in the WordPress comments table and can be used to verify that WordPress data is stored in MariaDB.

### Search the Project Files

```bash
grep -rni "" .
```

Recursively prints the contents of files in the current project directory with file names and line numbers. A search term can be placed between the quotation marks when checking for a specific configuration value.

### Clean Docker Before Evaluation

```bash
sudo docker stop $(sudo docker ps -qa)
sudo docker rm $(sudo docker ps -qa)
sudo docker rmi -f $(sudo docker images -qa)
sudo docker volume rm $(sudo docker volume ls -q)
sudo docker network rm $(sudo docker network ls -q) 2>/dev/null
```

These commands stop and remove existing containers, remove Docker images and volumes, and remove Docker networks. They are used before building the submitted project so that the evaluation starts from a clean Docker environment.
