# User Documentation

## Starting the Project

From the root of the repository, run:

```bash
make
```

This creates the required data directories, builds the Docker images and starts the infrastructure.

The website is available at:

`https://jkorvenp.42.fr`

A browser may display a warning because the project uses a self-signed TLS certificate.

## Stopping the Project

To stop and remove the containers while keeping the persistent WordPress and MariaDB data:

```bash
make down
```

To start the infrastructure again:

```bash
make up
```

## Accessing WordPress

The public website is available at:

`https://jkorvenp.42.fr`

The WordPress administration interface is available at:

`https://jkorvenp.42.fr/wp-admin`

If the user is not already authenticated, WordPress redirects to its login page.

## Credentials

Passwords are not stored in the repository.

Runtime configuration is provided through:

- `srcs/.env`
- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`

The `.env` file and `secrets/` directory are ignored by Git.

## Checking the Services

To display the running services:

```bash
sudo docker compose -f srcs/docker-compose.yml ps
```

The expected services are:

- `nginx`
- `wordpress`
- `mariadb`

NGINX is the only service that exposes a host port and is available on port 443.

To display the Docker volumes:

```bash
sudo docker volume ls
```

The project uses:

- `wordpress_data`
- `mariadb_data`

Persistent files are stored on the host under:

- `/home/jkorvenp/data/wordpress`
- `/home/jkorvenp/data/mariadb`