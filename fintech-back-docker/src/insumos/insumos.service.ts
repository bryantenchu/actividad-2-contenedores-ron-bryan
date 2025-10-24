import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Insumo } from './entities/insumo.entity';

@Injectable()
export class InsumosService {
  constructor(
    @InjectRepository(Insumo)
    private insumosRepository: Repository<Insumo>,
  ) {}

  async findAll() {
    const insumos = await this.insumosRepository.find();
    return { insumos };
  }
}

