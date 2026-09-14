*This project has been created as part of the 42 curriculum by jkorvenp.*

# Inception

## Description

Inception is a system administration project that uses Docker Compose to build and run a small infrastructure composed of several services.

The mandatory infrastructure contains three services:

- NGINX with TLSv1.2 and TLSv1.3 as the only external entry point.
- WordPress running with PHP-FPM.
- MariaDB for WordPress data.

Each service runs in its own container and is built from its own Dockerfile based on Alpine Linux.

The services communicate through a dedicated Docker network.

Persistent data is stored on the host in:

- `/home/jkorvenp/data/wordpress`
- `/home/jkorvenp/data/mariadb`

Docker volumes connect these directories to the WordPress and MariaDB containers.

NGINX is the only service exposing a port outside the Docker network and is accessible through port 443.

The website is available at:

`https://jkorvenp.42.fr`

## Instructions

The project requires Docker, Docker Compose and Make.

Create the required `.env` file in `srcs/` and the required secret files in `secrets/` before starting the project.

The environment contains the non-secret configuration required by the services, while passwords are stored separately using Docker secrets.

Build and start the infrastructure with:

```bash
make
```

Start the existing infrastructure without forcing a rebuild:

```bash
make up
```

Stop and remove the containers while preserving persistent data:

```bash
make down
```

Stop the infrastructure and remove Docker volumes:

```bash
make clean
```

Remove the infrastructure and persistent host data:

```bash
make fclean
```

Completely reset and rebuild the infrastructure:

```bash
make re
```

The domain `jkorvenp.42.fr` must resolve to the machine running the infrastructure.

## Resources

Resources used while working on the project included:

- Docker documentation
- Docker Compose documentation
- NGINX documentation
- WordPress documentation
- MariaDB documentation
- Alpine Linux documentation
- 42 Inception subject and evaluation criteria

These resources were used to understand containerization, Docker networking and volumes, TLS configuration, WordPress/PHP-FPM configuration, and MariaDB setup.

## AI Use

AI tools were used during the project

- Understanding Docker concepts: images, containers, volumes, networks, and persistent data
- Writing and debugging Dockerfiles and shell scripts, and configuring the VM network
- Writing project documentation

AI-generated suggestions were reviewed and tested against the project requirements and the actual behavior of the infrastructure.