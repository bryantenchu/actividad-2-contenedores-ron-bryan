"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.InsumosService = void 0;
const common_1 = require("@nestjs/common");
let InsumosService = class InsumosService {
    insumos = [
        {
            id: 1,
            nombre: 'Bolígrafos azules',
            cantidad: 50,
            precio: 15.0,
        },
        {
            id: 2,
            nombre: 'Resmas de papel A4',
            cantidad: 10,
            precio: 120.0,
        },
        {
            id: 3,
            nombre: 'Carpetas archivadoras',
            cantidad: 25,
            precio: 85.0,
        },
        {
            id: 4,
            nombre: 'Marcadores permanentes',
            cantidad: 30,
            precio: 45.0,
        },
        {
            id: 5,
            nombre: 'Clips metálicos',
            cantidad: 100,
            precio: 12.5,
        },
        {
            id: 6,
            nombre: 'Grapadoras',
            cantidad: 5,
            precio: 75.0,
        },
        {
            id: 7,
            nombre: 'Libretas tamaño carta',
            cantidad: 20,
            precio: 60.0,
        },
        {
            id: 8,
            nombre: 'Post-it variados',
            cantidad: 40,
            precio: 35.0,
        },
    ];
    findAll() {
        return { insumos: this.insumos };
    }
};
exports.InsumosService = InsumosService;
exports.InsumosService = InsumosService = __decorate([
    (0, common_1.Injectable)()
], InsumosService);
//# sourceMappingURL=insumos.service.js.map