WEBAPP_DIR=webapp
ERT_API_DIR=ert-api
ERT_ADAPTER_DIR=ert-adapter
NGINX_DIR=nginx
DATABASE_DIR=database

API_CMD=$(shell docker compose exec api)

SEPARATOR="---------------"

INFO=$(shell tput setab 3 && tput bold)
OK=$(shell tput setab 2 && tput bold)
PROMPT=$(shell tput setaf 6 && tput bold)
RESET=$(shell tput sgr0)

####################
#  INFRASTRUCTURE  #
####################

install: configure \
		 build \
		 start \
		 finish

###############
#  CONFIGURE  #
###############

configure: configure-database \
		   configure-adminer \
		   configure-ert-api \
		   configure-ert-adapter \
		   configure-webapp

configure-database:
	@echo "\n$(INFO) [INFO] Generating env file for database service $(RESET)\n"
	@cp ./database/mariadb.env.dist ./database/mariadb.env
	
	@echo "\n$(INFO) Configure variables for database server : $(RESET)\n"

	@echo "\n$(PROMPT)MARIADB_ROOT_PASSWORD ? $(RESET)"
	@read MARIADB_ROOT_PASSWORD; \
	 sed -i "s/MARIADB_ROOT_PASSWORD=.*/MARIADB_ROOT_PASSWORD=\"$$MARIADB_ROOT_PASSWORD\"/" ./$(DATABASE_DIR)/mariadb.env;

	@echo "\n$(PROMPT)MARIADB_USER ? $(RESET)"
	@read MARIADB_USER; \
	 sed -i "s/MARIADB_USER=.*/MARIADB_USER=\"$$MARIADB_USER\"/" ./$(DATABASE_DIR)/mariadb.env;

	@echo "\n$(PROMPT)MARIADB_PASSWORD ? $(RESET)"
	@read MARIADB_PASSWORD; \
	 sed -i "s/MARIADB_PASSWORD=.*/MARIADB_PASSWORD=\"$$MARIADB_PASSWORD\"/" ./$(DATABASE_DIR)/mariadb.env;

	@echo "\n$(PROMPT)MARIADB_DATABASE ? $(RESET)"
	@read MARIADB_DATABASE; \
	 sed -i "s/MARIADB_DATABASE=.*/MARIADB_DATABASE=\"$$MARIADB_DATABASE\"/" ./$(DATABASE_DIR)/mariadb.env;
	 
	@echo "\n$(OK) [OK] Generated env file for database service $(RESET)\n"
	@echo $(SEPARATOR)

configure-adminer: 
	@echo "\n$(INFO) [INFO] Generating env file for adminer service $(RESET)\n"
	@cp ./$(DATABASE_DIR)/adminer.env.dist ./$(DATABASE_DIR)/adminer.env
	@sed -i "s/ADMINER_DEFAULT_SERVER=.*/ADMINER_DEFAULT_SERVER=\"database\"/" ./$(DATABASE_DIR)/adminer.env;
	
	@echo "\n$(OK) [OK] Generated env file for adminer service $(RESET)\n"
	@echo $(SEPARATOR)

configure-ert-api: 
	@echo "\n$(INFO) [INFO] Copying configuration files to ert-api directory $(RESET)\n"
	@cp ./$(ERT_API_DIR)/.env.dist ./$(ERT_API_DIR)/.env

	@sed -i "s/DATABASE_HOST=.*/DATABASE_HOST=\"database\"/" ./$(ERT_API_DIR)/.env;
	@sed -i "s/DATABASE_PORT=.*/DATABASE_PORT=\"3306\"/" ./$(ERT_API_DIR)/.env;

	@DATABASE_USER=$$(grep -oP '^MARIADB_USER=\K.*' ./$(DATABASE_DIR)/mariadb.env); \
	 sed -i "s/DATABASE_USER=.*/DATABASE_USER=$$DATABASE_USER/" ./$(ERT_API_DIR)/.env;

	@DATABASE_PASSWORD=$$(grep -oP '^MARIADB_PASSWORD=\K.*' ./$(DATABASE_DIR)/mariadb.env); \
	 sed -i "s/DATABASE_PASSWORD=.*/DATABASE_PASSWORD=$$DATABASE_PASSWORD/" ./$(ERT_API_DIR)/.env;

	@DATABASE_NAME=$$(grep -oP '^MARIADB_DATABASE=\K.*' ./$(DATABASE_DIR)/mariadb.env); \
	 sed -i "s/DATABASE_NAME=.*/DATABASE_NAME=$$DATABASE_NAME/" ./$(ERT_API_DIR)/.env;

	@cp ./$(ERT_API_DIR)/.env ../$(ERT_API_DIR)/.env
	@cp ./$(ERT_API_DIR)/php/xdebug.ini ../$(ERT_API_DIR)/xdebug.ini
	@cp ./$(ERT_API_DIR)/Dockerfile ../$(ERT_API_DIR)
	@cp ./$(ERT_API_DIR)/.dockerignore ../$(ERT_API_DIR)

	@echo "\n$(OK) [OK] Copied configuration files to ert-api directory $(RESET)\n"

	@echo $(SEPARATOR)

configure-ert-adapter: 
	@echo "\n$(INFO) [INFO] Copying configuration files to ert-adapter directory $(RESET)\n"
	@cp ./$(ERT_ADAPTER_DIR)/.env.dist ./$(ERT_ADAPTER_DIR)/.env

	@cp ./$(ERT_ADAPTER_DIR)/.env ../$(ERT_ADAPTER_DIR)/.env
	@cp ./$(ERT_ADAPTER_DIR)/php/xdebug.ini ../$(ERT_ADAPTER_DIR)/xdebug.ini
	@cp ./$(ERT_ADAPTER_DIR)/Dockerfile ../$(ERT_ADAPTER_DIR)
	@cp ./$(ERT_ADAPTER_DIR)/.dockerignore ../$(ERT_ADAPTER_DIR)

	@echo "\n$(OK) [OK] Copied configuration files to ert-adapter directory $(RESET)\n"

	@echo $(SEPARATOR)

configure-webapp: 
	@echo $(SEPARATOR)
	@echo "\n$(INFO) [INFO] Copying configuration files to webapp directory $(RESET)\n"
	cp ./$(WEBAPP_DIR)/.env.dist ./$(WEBAPP_DIR)/.env
	cp ./$(WEBAPP_DIR)/.env.dist ../$(WEBAPP_DIR)/.env
	cp ./$(WEBAPP_DIR)/Dockerfile ../$(WEBAPP_DIR)
	cp ./$(WEBAPP_DIR)/.dockerignore ../$(WEBAPP_DIR)
	cp ./$(WEBAPP_DIR)/entrypoint.sh ../$(WEBAPP_DIR)
	@echo "\n$(OK) [OK] Copied configuration files to webapp directory $(RESET)\n"

###################
#  END CONFIGURE  #
###################

###########
#  BUILD  #
###########

build: build-ert-api \
	   build-ert-adapter \
	   build-webapp \
	   build-nginx

build-ert-api:
	@echo "\n$(INFO) [INFO] Building ert-api service $(RESET)\n"
	docker compose build ert-api
	@echo "\n$(OK) [OK] ert-api service built $(RESET)\n"
	@echo $(SEPARATOR)

build-ert-adapter:
	@echo "\n$(INFO) [INFO] Building ert-adapterq service $(RESET)\n"
	docker compose build ert-adapter
	@echo "\n$(OK) [OK] ert-adapter service built $(RESET)\n"
	@echo $(SEPARATOR)

build-webapp:
	@echo "\n$(INFO) [INFO] Building webapp service $(RESET)\n"
	docker compose build webapp
	@echo "\n$(OK) [OK] webapp service built $(RESET)\n"
	@echo $(SEPARATOR)

build-nginx:
	@echo "\n$(INFO) [INFO] Building nginx service $(RESET)\n"
	docker compose build ert-api-nginx
	docker compose build ert-adapter-nginx
	@echo "\n$(OK) [OK] nginx service started $(RESET)\n"
	@echo $(SEPARATOR)

###############
#  END BUILD  #
###############

###########
#  START  #
###########

start: start-redis \
	   start-rabbitmq \
	   start-database \
	   start-adminer \
	   start-ert-api \
	   start-ert-adapter \
	   start-webapp \
	   start-nginx 

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

start-database:
	@echo "\n$(INFO) [INFO] Starting database service $(RESET)\n"
	docker compose up -d database
	@echo "\n$(OK) [OK] database service started $(RESET)\n"
	@echo $(SEPARATOR)

start-adminer:
	@echo "\n$(INFO) [INFO] Starting adminer service $(RESET)\n"
	docker compose up -d adminer
	@echo "\n$(OK) [OK] adminer service started $(RESET)\n"
	@echo $(SEPARATOR)

start-ert-api:
	@echo "\n$(INFO) [INFO] Starting ert-api service $(RESET)\n"
	docker compose up -d ert-api
	@echo "\n$(OK) [OK] ert-api service started $(RESET)\n"
	@echo $(SEPARATOR)

start-ert-adapter:
	@echo "\n$(INFO) [INFO] Starting ert-adapter service $(RESET)\n"
	docker compose up -d ert-adapter
	@echo "\n$(OK) [OK] ert-adapter service started $(RESET)\n"
	@echo $(SEPARATOR)

start-webapp:
	@echo "\n$(INFO) [INFO] Starting webapp service $(RESET)\n"
	docker compose up -d webapp
	@echo "\n$(OK) [OK] webapp service started $(RESET)\n"
	@echo $(SEPARATOR)

start-nginx:
	@echo "\n$(INFO) [INFO] Starting nginx services $(RESET)\n"
	docker compose up -d ert-api-nginx
	docker compose up -d ert-adapter-nginx
	@echo "\n$(OK) [OK] nginx services started $(RESET)\n"
	@echo $(SEPARATOR)

###############
#  END START  #
###############

############
#  FINISH  #
############

finish: finish-ert-api \
		finish-ert-adapter \
		finish-webapp

finish-ert-api:
	docker exec ert-api composer install

finish-ert-adapter:
	docker exec ert-adapter composer install

finish-webapp:
	docker exec webapp npm i

################
#  END FINISH  #
################

########################
#  END INFRASTRUCTURE  #
########################
