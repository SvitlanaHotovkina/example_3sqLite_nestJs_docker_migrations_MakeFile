import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';
@Entity()
export class Logs {
  @PrimaryGeneratedColumn() id: number;
  @Column() action: string;
  @CreateDateColumn() createdAt: Date;
}
