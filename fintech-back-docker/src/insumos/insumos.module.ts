import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InsumosController } from './insumos.controller';
import { InsumosService } from './insumos.service';
import { Insumo } from './entities/insumo.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Insumo])],
  controllers: [InsumosController],
  providers: [InsumosService],
})
export class InsumosModule {}

