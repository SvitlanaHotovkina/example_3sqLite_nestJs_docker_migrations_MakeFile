#!/bin/sh
echo "🚀 Запуск NestJS в фоне..."
npm run start:dev & 
NEST_PID=$!
echo "🕒 Ожидание запуска приложения..."
sleep 2
echo "📦 Создание новой миграции..."
npx typeorm-ts-node-commonjs migration:create ./migrations/InitMigration
echo "🔄 Генерация изменений в миграции..."
npx typeorm-ts-node-commonjs migration:generate ./migrations/InitMigration -d ./src/config/typeorm.config.ts
echo "✅ Применение миграций..."
npx typeorm-ts-node-commonjs migration:run -d ./src/config/typeorm.config.ts
sleep 2
echo "🛑 Завершаем старый процесс NestJS (PID $NEST_PID)..."
sleep 2
kill $NEST_PID
wait $NEST_PID
