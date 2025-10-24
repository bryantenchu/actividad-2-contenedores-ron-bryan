import { Controller, Get } from '@nestjs/common';
import { InsumosService } from './insumos.service';

@Controller('insumos')
export class InsumosController {
  constructor(private readonly insumosService: InsumosService) {}

  @Get()
  async findAll() {
    return await this.insumosService.findAll();
  }
}

