NAME = inception

COMPOSE = sudo docker compose -f srcs/docker-compose.yml

DATA_DIR = /home/jkorvenp/data
MARIADB_DIR = $(DATA_DIR)/mariadb
WORDPRESS_DIR = $(DATA_DIR)/wordpress

all: dirs
	$(COMPOSE) up --build -d

dirs:
	sudo mkdir -p $(MARIADB_DIR)
	sudo mkdir -p $(WORDPRESS_DIR)

up: dirs
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all dirs up down clean fclean re