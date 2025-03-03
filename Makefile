# Variables
PROJECT_NAME = my-nest-project
DOCKER_COMPOSE = docker-compose
DOCKER = docker

# Creates a new NestJS project
setup:
	npx @nestjs/cli new $(PROJECT_NAME) --package-manager npm
	cd $(PROJECT_NAME) && npm install @nestjs/typeorm typeorm dotenv
	cd $(PROJECT_NAME) && npm install sqlite3 --save

# Creates the basic project structure
init-structure:
	mkdir -p $(PROJECT_NAME)/src/entities
	mkdir -p $(PROJECT_NAME)/src/config
	cd $(PROJECT_NAME) && npx @nestjs/cli generate module logs
	cd $(PROJECT_NAME) && npx @nestjs/cli generate controller logs
	cd $(PROJECT_NAME) && npx @nestjs/cli generate service logs

# Creates ORM configuration with DataSourceOptions
create-ormconfig:
	echo 'import { DataSource, DataSourceOptions } from "typeorm";' > $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo 'import { join } from "path";' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo 'const opt: DataSourceOptions = {' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '  type: "sqlite",' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '  database: join(process.cwd(), "/db/logs.sqlite"),' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '  entities: [join(process.cwd(), "/dist/**/*.entity.{ts,js}")],' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '  migrations: [join(process.cwd(), "/migrations/*.ts")],' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '  synchronize: false,' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '  logging: true,' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '};' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo 'const AppDataSource = new DataSource(opt);' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo 'console.log("conf", opt);' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo '' >> $(PROJECT_NAME)/src/config/typeorm.config.ts
	echo 'export default AppDataSource;' >> $(PROJECT_NAME)/src/config/typeorm.config.ts

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
	cd  $(PROJECT_NAME) && npx typeorm-ts-node-commonjs migration:generate ./migrations/InitMigration -d ./src/config/typeorm.config.ts
    cd  $(PROJECT_NAME) && npx typeorm-ts-node-commonjs migration:run -d ./src/config/typeorm.config.ts


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

# Updates LogsModule to include TypeORM support with forRootAsync()
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
	echo 'import { TypeOrmModule, TypeOrmModuleOptions } from "@nestjs/typeorm";' >> $(PROJECT_NAME)/src/app.module.ts
	echo 'import { LogsModule } from "./logs/logs.module";' >> $(PROJECT_NAME)/src/app.module.ts
	echo 'import { join } from "path";' >> $(PROJECT_NAME)/src/app.module.ts
	echo '' >> $(PROJECT_NAME)/src/app.module.ts
	echo '@Module({' >> $(PROJECT_NAME)/src/app.module.ts
	echo '  imports: [' >> $(PROJECT_NAME)/src/app.module.ts
	echo '    TypeOrmModule.forRootAsync({' >> $(PROJECT_NAME)/src/app.module.ts
	echo '      useFactory: () => {' >> $(PROJECT_NAME)/src/app.module.ts
	echo '        const opt: TypeOrmModuleOptions = {' >> $(PROJECT_NAME)/src/app.module.ts
	echo '          type: "sqlite",' >> $(PROJECT_NAME)/src/app.module.ts
	echo '          database: join(process.cwd(), "/db/logs.sqlite"),' >> $(PROJECT_NAME)/src/app.module.ts
	echo '          entities: [join(process.cwd(), "/dist/**/*.entity.{ts,js}")],' >> $(PROJECT_NAME)/src/app.module.ts
	echo '          synchronize: false,' >> $(PROJECT_NAME)/src/app.module.ts
	echo '          logging: true,' >> $(PROJECT_NAME)/src/app.module.ts
	echo '        };' >> $(PROJECT_NAME)/src/app.module.ts
	echo '        console.log("app", opt);' >> $(PROJECT_NAME)/src/app.module.ts
	echo '        return opt;' >> $(PROJECT_NAME)/src/app.module.ts
	echo '      },' >> $(PROJECT_NAME)/src/app.module.ts
	echo '    }),' >> $(PROJECT_NAME)/src/app.module.ts
	echo '    LogsModule,' >> $(PROJECT_NAME)/src/app.module.ts
	echo '  ],' >> $(PROJECT_NAME)/src/app.module.ts
	echo '})' >> $(PROJECT_NAME)/src/app.module.ts
	echo 'export class AppModule {}' >> $(PROJECT_NAME)/src/app.module.ts

add-scripts:
	cd  $(PROJECT_NAME) && jq '.scripts += {"migration:create": "npx typeorm-ts-node-commonjs migration:create ./migrations/InitMigration "}' package.json > temp.json && mv temp.json package.json
	cd  $(PROJECT_NAME) && jq '.scripts += {"migration:generate": "npm run build && npx typeorm-ts-node-commonjs migration:generate ./migrations/InitMigration -d ./src/config/typeorm.config.ts"}' package.json > temp.json && mv temp.json package.json
	cd  $(PROJECT_NAME) && jq '.scripts += {"migration:run": "npx typeorm-ts-node-commonjs migration:run -d ./src/config/typeorm.config.ts"}' package.json > temp.json && mv temp.json package.json
	cd  $(PROJECT_NAME) && jq '.scripts += {"migration:revert": "npx typeorm-ts-node-commonjs migration:revert -d ./src/config/typeorm.config.ts"}' package.json > temp.json && mv temp.json package.json


# Создает Dockerfile с нужными зависимостями
create-dockerfile-m:
	echo 'FROM node:20' > $(PROJECT_NAME)/Dockerfile.migration
	echo 'RUN apt-get update && apt-get install -y sqlite3 jq' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'RUN npm install -g ts-node typeorm ' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'WORKDIR /app' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'COPY package*.json ./' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'RUN npm install' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'COPY . .' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'RUN mkdir -p db' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'COPY docker-entrypoint.sh /docker-entrypoint.sh' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'RUN chmod +x /docker-entrypoint.sh' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'EXPOSE 3000' >> $(PROJECT_NAME)/Dockerfile.migration
	echo 'CMD ENTRYPOINT ["/docker-entrypoint.sh"] ' >> $(PROJECT_NAME)/Dockerfile.migration


# Создает Dockerfile с нужными зависимостями
create-dockerfile-app:
	echo 'FROM node:20' > $(PROJECT_NAME)/Dockerfile.app
	echo 'RUN apt-get update && apt-get install -y sqlite3 jq' >> $(PROJECT_NAME)/Dockerfile.app
	echo 'RUN npm install -g ts-node typeorm ' >> $(PROJECT_NAME)/Dockerfile.app
	echo 'WORKDIR /app' >> $(PROJECT_NAME)/Dockerfile.app
	echo 'COPY package*.json ./' >> $(PROJECT_NAME)/Dockerfile.app
	echo 'RUN npm install' >> $(PROJECT_NAME)/Dockerfile.app
	echo 'COPY . .' >> $(PROJECT_NAME)/Dockerfile.app
	echo 'EXPOSE 3000' >> $(PROJECT_NAME)/Dockerfile.app
	echo 'RUN npm run build' >> $(PROJECT_NAME)/Dockerfile.app
	echo 'CMD ["npm", "run", "start:dev"] ' >> $(PROJECT_NAME)/Dockerfile.app

# Создает docker-entrypoint.sh с генерацией, применением миграций и перезапуском NestJS
create-docker-entrypoint:
	echo '#!/bin/sh' > $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'echo "🚀 Запуск NestJS в фоне..."' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'npm run start:dev & ' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'NEST_PID=$$!' >> $(PROJECT_NAME)/docker-entrypoint.sh # Сохраняем PID процесса NestJS
	echo 'echo "🕒 Ожидание запуска приложения..."' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'sleep 2' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'echo "📦 Создание новой миграции..."' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'npx typeorm-ts-node-commonjs migration:create ./migrations/InitMigration' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'echo "🔄 Генерация изменений в миграции..."' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'npx typeorm-ts-node-commonjs migration:generate ./migrations/InitMigration -d ./src/config/typeorm.config.ts' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'echo "✅ Применение миграций..."' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'npx typeorm-ts-node-commonjs migration:run -d ./src/config/typeorm.config.ts' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'sleep 2' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'echo "🛑 Завершаем старый процесс NestJS (PID $$NEST_PID)..."' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'sleep 2' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'kill $$NEST_PID' >> $(PROJECT_NAME)/docker-entrypoint.sh
	echo 'wait $$NEST_PID' >> $(PROJECT_NAME)/docker-entrypoint.sh
	

# Creates `docker-compose.yml`
create-docker-compose:
	echo 'version: "3.8"' > $(PROJECT_NAME)/docker-compose.yml
	echo '' >> $(PROJECT_NAME)/docker-compose.yml
	echo 'services:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '  migrations:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    container_name: nest-migrations' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    build:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      context: .' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      dockerfile: Dockerfile.migration' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    volumes:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - ./db:/app/db' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - .:/app' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    environment:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      NODE_ENV: development' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    entrypoint: ["/docker-entrypoint.sh"]' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    restart: "no"' >> $(PROJECT_NAME)/docker-compose.yml
	echo '' >> $(PROJECT_NAME)/docker-compose.yml
	echo '  app:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    container_name: nest-app' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    build:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      context: .' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      dockerfile: Dockerfile.app' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    depends_on:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - migrations' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    ports:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - "3000:3000"' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    volumes:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - ./db:/app/db' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      - .:/app' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    environment:' >> $(PROJECT_NAME)/docker-compose.yml
	echo '      NODE_ENV: development' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    restart: unless-stopped' >> $(PROJECT_NAME)/docker-compose.yml
	echo '    command: npm run start:dev' >> $(PROJECT_NAME)/docker-compose.yml

# Runs all initialization commands
init: setup init-structure create-ormconfig update-logs-service update-logs-module update-modules init-entities add-scripts create-docker-entrypoint create-dockerfile-app create-dockerfile-m create-docker-compose

# Starts the application in Docker
start:
	cd $(PROJECT_NAME) && $(DOCKER_COMPOSE) up --build

# Stops the container
stop:
	cd $(PROJECT_NAME) && $(DOCKER_COMPOSE) down

migrate-run:
	cd $(PROJECT_NAME) && $(DOCKER) exec nest-app npm run migration:run 
migrate-create:
	cd $(PROJECT_NAME) && $(DOCKER) exec nest-app npm run migration:create 
migrate-g:
	cd $(PROJECT_NAME) && $(DOCKER) exec nest-app npm run migration:generate 

migrate-revert:
	cd $(PROJECT_NAME) && $(DOCKER) exec nest-app npm run  migration:revert


# Cleans up cache
clean:
	sudo rm -rf $(PROJECT_NAME)/node_modules $(PROJECT_NAME)/dist $(PROJECT_NAME)/db $(PROJECT_NAME)/migrations

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
