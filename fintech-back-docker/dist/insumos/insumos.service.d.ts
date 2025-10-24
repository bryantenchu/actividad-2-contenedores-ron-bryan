export declare class InsumosService {
    private readonly insumos;
    findAll(): {
        insumos: {
            id: number;
            nombre: string;
            cantidad: number;
            precio: number;
        }[];
    };
}
