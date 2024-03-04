DOCKER_WEBAPP=$(docker exec webapp)

configure-webapp: 
	@echo "Copying configuration files to webapp directory"
	@cp ./webapp/.env.dist ../webapp/.env
	@cp ./webapp/Dockerfile ../webapp
	@cp ./webapp/.dockerignore ../webapp
	@cp ./webapp/entrypoint.sh ../webapp

build-webapp: configure-webapp
	@echo "Building webapp service"
	docker compose build webapp

start-webapp: build-webapp
	@echo "Running webapp service"
	docker compose up -d webapp

configure-api: 
	@echo "Copying configuration files to api directory"
	@cp ./api/.env.dist ../api/.env
	@cp ./api/Dockerfile ../api
	@cp ./api/.dockerignore ../api

build-api: configure-api
	@echo "Building api service"
	docker compose build api

start-api: build-api
	@echo "Running api service"
	docker compose up -d api

build-nginx: 
	@echo "Building nginx service"
	docker compose build nginx

start-nginx:
	@echo "Starting nginx service"
	docker compose up -d nginx

start: start-webapp start-api start-nginx

restart:
	@echo "Restarting Stack"
	@docker stop $$(docker ps -aq) && \
	docker rm $$(docker ps -aq) && \
	docker rmi $$(docker images -q)
	@echo "Rebuilding & Restarting services"
	docker compose up -d