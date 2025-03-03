import { DataSource, DataSourceOptions } from 'typeorm';
import { join } from 'path';

const opt: DataSourceOptions = {
  type: 'sqlite',
  database: join(process.cwd(), '/db/logs.sqlite'),
  entities: [join(process.cwd(), '/dist/**/*.entity.{ts,js}')],
  migrations: [join(process.cwd(), '/migrations/*.ts')],
  synchronize: false,
  logging: true,
};

const AppDataSource = new DataSource(opt);

console.log('conf', opt);

export default AppDataSource;
