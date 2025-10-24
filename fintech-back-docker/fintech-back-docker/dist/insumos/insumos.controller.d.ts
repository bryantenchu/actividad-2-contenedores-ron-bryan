import { InsumosService } from './insumos.service';
export declare class InsumosController {
    private readonly insumosService;
    constructor(insumosService: InsumosService);
    findAll(): {
        insumos: {
            id: number;
            nombre: string;
            cantidad: number;
            precio: number;
        }[];
    };
}
