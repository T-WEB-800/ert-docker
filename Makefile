WEBAPP_DIR=webapp
API_DIR=api
NGINX_DIR=nginx

SEPARATOR="---------------"

INFO=$(shell tput setab 3 && tput bold)
OK=$(shell tput setab 2 && tput bold)
RESET=$(shell tput sgr0)

configure-webapp: 
	@echo $(SEPARATOR)
	@echo "\n$(INFO) [INFO] Copying configuration files to webapp directory $(RESET)\n"
	cp ./$(WEBAPP_DIR)/.env.dist ../$(WEBAPP_DIR)/.env
	cp ./$(WEBAPP_DIR)/Dockerfile ../$(WEBAPP_DIR)
	cp ./$(WEBAPP_DIR)/.dockerignore ../$(WEBAPP_DIR)
	cp ./$(WEBAPP_DIR)/entrypoint.sh ../$(WEBAPP_DIR)
	@echo "\n$(OK) [OK] Copied configuration files to webapp directory $(RESET)\n"

build-webapp: configure-webapp
	@echo "\n$(INFO) [INFO] Building webapp service $(RESET)\n"
	docker compose build webapp
	@echo "\n$(OK) [OK] webapp service built $(RESET)\n"
	@echo $(SEPARATOR)


start-webapp: build-webapp
	@echo "\n$(INFO) [INFO] Starting webapp service $(RESET)\n"
	docker compose up -d webapp
	@echo "\n$(OK) [OK] webapp service started $(RESET)\n"
	@echo $(SEPARATOR)

configure-api: 
	@echo "\n$(INFO) [INFO] Copying configuration files to api directory $(RESET)\n"
	cp ./$(API_DIR)/.env.dist ../$(API_DIR)/.env
	cp ./$(API_DIR)/Dockerfile ../$(API_DIR)
	cp ./$(API_DIR)/.dockerignore ../$(API_DIR)
	@echo "\n$(OK) [OK] Copied configuration files to api directory $(RESET)\n"
	@echo $(SEPARATOR)

build-api: configure-api
	@echo "\n$(INFO) [INFO] Building api service $(RESET)\n"
	docker compose build api
	@echo "\n$(OK) [OK] api service started $(RESET)\n"
	@echo $(SEPARATOR)

start-api: build-api
	@echo "\n$(INFO) [INFO] Starting api service $(RESET)\n"
	docker compose up -d api
	@echo "\n$(OK) [OK] api service started $(RESET)\n"
	@echo $(SEPARATOR)

build-nginx: 
	@echo "\n$(INFO) [INFO] Building nginx service $(RESET)\n"
	docker compose build nginx
	@echo "\n$(OK) [OK] nginx service started $(RESET)\n"
	@echo $(SEPARATOR)

start-nginx:
	@echo "\n$(INFO) [INFO] Starting nginx service $(RESET)\n"
	docker compose up -d nginx
	@echo "\n$(OK) [OK] nginx service started $(RESET)\n"
	@echo $(SEPARATOR)

start-redis:
	@echo "\n$(INFO) [INFO] Starting redis service $(RESET)\n"
	docker compose up -d redis
	@echo "\n$(OK) [OK] redis service started $(RESET)\n"
	@echo $(SEPARATOR)

start-rabbitmq:
	@echo "\n$(INFO) [INFO] Starting rabbitmq service $(RESET)\n"
	docker compose up -d rabbitmq
	@echo "\n$(OK) [OK] rabbitmq service started $(RESET)\n"
	@echo $(SEPARATOR)

start: start-redis \
	   start-rabbitmq \
	   start-api \
	   start-webapp \
	   start-nginx

restart:
	@echo "Stopping services"
	@docker compose rm -s -f
	@echo "Rebuilding & Restarting services"
	@docker compose up -d