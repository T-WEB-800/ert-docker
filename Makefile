WEBAPP_DIR=webapp
API_DIR=api
NGINX_DIR=nginx
DATABASE_DIR=database

API_CMD=$(shell docker compose exec api)

SEPARATOR="---------------"

INFO=$(shell tput setab 3 && tput bold)
OK=$(shell tput setab 2 && tput bold)
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
		   configure-api \
		   configure-webapp

configure-database:
	@echo "\n$(INFO) [INFO] Generating env file for database service $(RESET)\n"
	cp ./$(DATABASE_DIR)/mariadb.env.dist ./$(DATABASE_DIR)/mariadb.env
	@echo "\n$(OK) [OK] Generated env file for database service $(RESET)\n"
	@echo $(SEPARATOR)

configure-adminer: 
	@echo "\n$(INFO) [INFO] Generating env file for adminer service $(RESET)\n"
	cp ./$(DATABASE_DIR)/adminer.env.dist ./$(DATABASE_DIR)/adminer.env
	@echo "\n$(OK) [OK] Generated env file for adminer service $(RESET)\n"
	@echo $(SEPARATOR)

configure-api: 
	@echo "\n$(INFO) [INFO] Copying configuration files to api directory $(RESET)\n"
	cp ./$(API_DIR)/.env.dist ./$(API_DIR)/.env
	cp ./$(API_DIR)/.env.dist ../$(API_DIR)/.env
	cp ./$(API_DIR)/php/xdebug.ini ../$(API_DIR)/xdebug.ini
	cp ./$(API_DIR)/Dockerfile ../$(API_DIR)
	cp ./$(API_DIR)/.dockerignore ../$(API_DIR)
	@echo "\n$(OK) [OK] Copied configuration files to api directory $(RESET)\n"
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

build: build-api \
	   build-webapp \
	   build-nginx

build-api:
	@echo "\n$(INFO) [INFO] Building api service $(RESET)\n"
	docker compose build api
	@echo "\n$(OK) [OK] api service started $(RESET)\n"
	@echo $(SEPARATOR)

build-webapp:
	@echo "\n$(INFO) [INFO] Building webapp service $(RESET)\n"
	docker compose build webapp
	@echo "\n$(OK) [OK] webapp service built $(RESET)\n"
	@echo $(SEPARATOR)

build-nginx:
	@echo "\n$(INFO) [INFO] Building nginx service $(RESET)\n"
	docker compose build nginx
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
	   start-api \
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

start-api:
	@echo "\n$(INFO) [INFO] Starting api service $(RESET)\n"
	docker compose up -d api
	@echo "\n$(OK) [OK] api service started $(RESET)\n"
	@echo $(SEPARATOR)

start-webapp:
	@echo "\n$(INFO) [INFO] Starting webapp service $(RESET)\n"
	docker compose up -d webapp
	@echo "\n$(OK) [OK] webapp service started $(RESET)\n"
	@echo $(SEPARATOR)

start-nginx:
	@echo "\n$(INFO) [INFO] Starting nginx service $(RESET)\n"
	docker compose up -d nginx
	@echo "\n$(OK) [OK] nginx service started $(RESET)\n"
	@echo $(SEPARATOR)

###############
#  END START  #
###############

############
#  FINISH  #
############

finish: finish-api \
		finish-webapp

finish-api:
	docker exec api composer install

finish-webapp:
	docker exec webapp npm i

################
#  END FINISH  #
################


########################
#  END INFRASTRUCTURE  #
########################


###############
#  API UTILS  #
###############

api-unit-tests:
	$(API_CMD) php bin/phpunit

###################
#  END API UTILS  #
###################
