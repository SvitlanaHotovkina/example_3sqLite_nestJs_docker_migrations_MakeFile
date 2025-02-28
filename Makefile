# Variables
PROJECT_NAME = my-nest-project
DOCKER_COMPOSE = docker-compose
DOCKER = docker

# Creates a new NestJS project
setup:
	npx @nestjs/cli new $(PROJECT_NAME) --package-manager npm
	cd $(PROJECT_NAME) && npm install @nestjs/typeorm typeorm sqlite3 dotenv

# Creates the basic project structure
init-structure:
	mkdir -p $(PROJECT_NAME)/db
	mkdir -p $(PROJECT_NAME)/src/entities
	mkdir -p $(PROJECT_NAME)/src/migrations/logs
	cd $(PROJECT_NAME) && npx @nestjs/cli generate module logs
	cd $(PROJECT_NAME) && npx @nestjs/cli generate controller logs
	cd $(PROJECT_NAME) && npx @nestjs/cli generate service logs

# Creates ORM configuration
create-ormconfig:
	echo 'import { DataSource } from "typeorm";' > $(PROJECT_NAME)/typeorm.config.ts
	echo ' const AppDataSource = new DataSource({' >> $(PROJECT_NAME)/typeorm.config.ts
	echo '  type: "sqlite",' >> $(PROJECT_NAME)/typeorm.config.ts
	echo '  database: "db/logs.sqlite",' >> $(PROJECT_NAME)/typeorm.config.ts
	echo ' entities: ["src/**/*.entity{.ts,.js}"],' >> $(PROJECT_NAME)/typeorm.config.ts
	echo '  migrations: ["src/migrations/logs/*.ts"],' >> $(PROJECT_NAME)/typeorm.config.ts
	echo '  synchronize: false,' >> $(PROJECT_NAME)/typeorm.config.ts
	echo '});' >> $(PROJECT_NAME)/typeorm.config.ts
	echo 'export default AppDataSource ' >> $(PROJECT_NAME)/typeorm.config.ts


# Creates Entity files
init-entities:
	echo 'import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from "typeorm";' > $(PROJECT_NAME)/src/entities/logs.entity.ts
	echo '@Entity()' >> $(PROJECT_NAME)/src/entities/logs.entity.ts
	echo 'export class Logs {' >> $(PROJECT_NAME)/src/entities/logs.entity.ts
	echo '  @PrimaryGeneratedColumn() id: number;' >> $(PROJECT_NAME)/src/entities/logs.entity.ts
	echo '  @Column() action: string;' >> $(PROJECT_NAME)/src/entities/logs.entity.ts
	echo '  @CreateDateColumn() createdAt: Date;' >> $(PROJECT_NAME)/src/entities/logs.entity.ts
	echo '}' >> $(PROJECT_NAME)/src/entities/logs.entity.ts

# Creates Migration files
init-migrations:
	cd  $(PROJECT_NAME) && npm run build
	cd  $(PROJECT_NAME) && npx typeorm migration:create src/migrations/logs/CreateLogsTable
    cd  $(PROJECT_NAME) && npx typeorm migration:generate -d typeorm.config.ts src/migrations/logs


# Creates database file
init-database:
	touch $(PROJECT_NAME)/db/logs.sqlite

# Updates LogsService to log data every 10 seconds
update-logs-service:
	echo 'import { Injectable, OnModuleInit } from "@nestjs/common";' > $(PROJECT_NAME)/src/logs/logs.service.ts
	echo 'import { InjectRepository } from "@nestjs/typeorm";' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo 'import { Repository } from "typeorm";' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo 'import { Logs } from "../entities/logs.entity";' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '@Injectable()' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo 'export class LogsService implements OnModuleInit {' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '  constructor(@InjectRepository(Logs) private logsRepository: Repository<Logs>) {}' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '  onModuleInit() {' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '    setTimeout(() => {' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '      const log = this.logsRepository.create({ action: "Auto log entry" });' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '      this.logsRepository.save(log)' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '        .then((entity) =>' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '          this.logsRepository.findOneBy({ id: entity.id })' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '            .then((v) => console.log(v))' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '        )' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '        .catch((err) => console.log(err));' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '    }, 10000);' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '  }' >> $(PROJECT_NAME)/src/logs/logs.service.ts
	echo '}' >> $(PROJECT_NAME)/src/logs/logs.service.ts

# Updates LogsModule to include TypeORM support
update-logs-module:
	echo 'import { Module } from "@nestjs/common";' > $(PROJECT_NAME)/src/logs/logs.module.ts
	echo 'import { LogsController } from "./logs.controller";' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo 'import { LogsService } from "./logs.service";' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo 'import { Logs } from "../entities/logs.entity";' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo 'import { TypeOrmModule } from "@nestjs/typeorm";' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo '@Module({' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo '  imports: [TypeOrmModule.forFeature([Logs])],' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo '  controllers: [LogsController],' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo '  providers: [LogsService],' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo '})' >> $(PROJECT_NAME)/src/logs/logs.module.ts
	echo 'export class LogsModule {}' >> $(PROJECT_NAME)/src/logs/logs.module.ts


# Updates AppModule and LogsModule
update-modules:
	echo 'import { Module } from "@nestjs/common";' > $(PROJECT_NAME)/src/app.module.ts
	echo 'import { TypeOrmModule } from "@nestjs/typeorm";' >> $(PROJECT_NAME)/src/app.module.ts
	echo 'import { LogsModule } from "./logs/logs.module";' >> $(PROJECT_NAME)/src/app.module.ts
	echo 'import { Logs } from "./entities/logs.entity";' >> $(PROJECT_NAME)/src/app.module.ts
	echo '@Module({' >> $(PROJECT_NAME)/src/app.module.ts
	echo '  imports: [TypeOrmModule.forRoot({ type: "sqlite", database: "db/logs.sqlite", entities: [Logs], synchronize: true }), LogsModule],' >> $(PROJECT_NAME)/src/app.module.ts
	echo '})' >> $(PROJECT_NAME)/src/app.module.ts
	echo 'export class AppModule {}' >> $(PROJECT_NAME)/src/app.module.ts

# Creates `Dockerfile`
create-dockerfile:
	echo 'FROM node:20' > $(PROJECT_NAME)/Dockerfile
	echo 'WORKDIR /app' >> $(PROJECT_NAME)/Dockerfile
	echo 'COPY package*.json ./' >> $(PROJECT_NAME)/Dockerfile
	echo 'RUN npm install' >> $(PROJECT_NAME)/Dockerfile
	echo 'COPY . .' >> $(PROJECT_NAME)/Dockerfile
	echo 'RUN mkdir -p db' >> $(PROJECT_NAME)/Dockerfile
	echo 'EXPOSE 3000' >> $(PROJECT_NAME)/Dockerfile
	echo 'CMD npm run build && npm run typeorm migration:run -d typeorm.config.ts --name logs && npm start' >> $(PROJECT_NAME)/Dockerfile

# Creates `docker-compose.yml`
create-docker-compose:
	echo 'version: "3.8"' > $(PROJECT_NAME)/docker-compose.yml
	echo 'services:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '  app:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    container_name: nest-app' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    build: .' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    restart: unless-stopped' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    ports:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - "3000:3000"' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    volumes:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - ./db:/app/db' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - .:/app' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    environment:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      NODE_ENV: production' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    command: npm run start' >> $(PROJECT_NAME)/docker-compose.yml

# Runs all initialization commands
init: setup init-structure init-database create-ormconfig update-logs-service update-logs-module update-modules init-entities init-migrations create-dockerfile create-docker-compose

# Starts the application in Docker
start:
	cd $(PROJECT_NAME) && $(DOCKER_COMPOSE) up --build -d

# Stops the container
stop:
	cd $(PROJECT_NAME) && $(DOCKER_COMPOSE) down

migrate:
	cd $(PROJECT_NAME) && $(DOCKER) exec nest-app npm run typeorm migration:run -d ormconfig.ts

migrate-revert:
	cd $(PROJECT_NAME) && $(DOCKER) exec nest-app npm run typeorm migration:revert -d ormconfig.ts


# Cleans up cache
clean:
	rm -rf $(PROJECT_NAME)/node_modules $(PROJECT_NAME)/dist

# Reinstalls dependencies from scratch
reinstall:
	rm -rf $(PROJECT_NAME)/node_modules $(PROJECT_NAME)/package-lock.json
	cd $(PROJECT_NAME) && npm install

# Shows logs from the container
logs:
	cd $(PROJECT_NAME) && $(DOCKER_COMPOSE) logs -f

# Displays available commands
help:
	@echo "Available commands:"
	@echo "  make init             - Create project and structure"
	@echo "  make start            - Start the Docker container"
	@echo "  make stop             - Stop the Docker container"
	@echo "  make migrate          - Run database migrations"
	@echo "  make migrate-revert   - Revert the last migration"
	@echo "  make clean            - Clear NestJS cache"
	@echo "  make reinstall        - Reinstall dependencies"
	@echo "  make logs             - View container logs"
