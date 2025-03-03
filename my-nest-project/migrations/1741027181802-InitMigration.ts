import { MigrationInterface, QueryRunner } from "typeorm";

export class InitMigration1741027181802 implements MigrationInterface {
    name = 'InitMigration1741027181802'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "logs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "action" varchar NOT NULL, "createdAt" datetime NOT NULL DEFAULT (datetime('now')))`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "logs"`);
    }

}
