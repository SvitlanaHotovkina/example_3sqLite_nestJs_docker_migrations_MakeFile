import { Module } from '@nestjs/common';
import { TypeOrmModule, TypeOrmModuleOptions } from '@nestjs/typeorm';
import { LogsModule } from './logs/logs.module';
import { join } from 'path';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      useFactory: () => {
        const opt: TypeOrmModuleOptions = {
          type: 'sqlite',
          database: join(process.cwd(), '/db/logs.sqlite'),
          entities: [join(process.cwd(), '/dist/**/*.entity.{ts,js}')],
          synchronize: false,
          logging: true,
        };
        console.log('app', opt);
        return opt;
      },
    }),
    LogsModule,
  ],
})
export class AppModule {}
