NAME = inception

COMPOSE = sudo docker compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up --build -d

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean

re: fclean all

.PHONY: all up down clean fclean re