<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AccountingEngineConfigSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Funciones auxiliares para obtener IDs fácilmente
        $getAccount = fn($code) => \App\Models\AccountingAccount::where('code', $code)->value('id');
        
        $caja = $getAccount('1101');
        $banco = $getAccount('1102');
        $itbis = $getAccount('2102');
        $cxp = $getAccount('2100'); // Cuentas por pagar

        if (!$caja) return; // Si no hay cuentas, no seedear

        $operations = [
            [
                'operation_code' => 'DIEZMO',
                'name' => 'Ingreso por Diezmos',
                'debit_account_id' => $caja,
                'credit_account_id' => $getAccount('4100'),
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
            [
                'operation_code' => 'OFRENDA',
                'name' => 'Ingreso por Ofrendas',
                'debit_account_id' => $caja,
                'credit_account_id' => $getAccount('4101'),
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
            [
                'operation_code' => 'DONACION_LOCAL',
                'name' => 'Ingreso por Donación Local',
                'debit_account_id' => $caja,
                'credit_account_id' => $getAccount('4104'),
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
            [
                'operation_code' => 'VENTA_LIBRERIA',
                'name' => 'Venta en Librería (Con ITBIS)',
                'debit_account_id' => $caja,
                'credit_account_id' => $getAccount('4102'),
                'tax_account_id' => $itbis,
                'tax_percentage' => 18.00,
            ],
            [
                'operation_code' => 'VENTA_CAFETERIA',
                'name' => 'Venta en Cafetería (Sin ITBIS)',
                'debit_account_id' => $caja,
                'credit_account_id' => $getAccount('4103'),
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
            [
                'operation_code' => 'COMPRA_INV_LIBRERIA',
                'name' => 'Compra Inventario Librería (Al Contado)',
                'debit_account_id' => $getAccount('1104'), // Aumenta Inventario
                'credit_account_id' => $caja, // Disminuye Caja
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
            [
                'operation_code' => 'PAGO_NOMINA',
                'name' => 'Pago de Nómina',
                'debit_account_id' => $getAccount('5102'), // Aumenta Gasto
                'credit_account_id' => $banco, // Disminuye Banco
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
            [
                'operation_code' => 'PAGO_SERVICIOS',
                'name' => 'Pago de Servicios Públicos',
                'debit_account_id' => $getAccount('5103'), // Aumenta Gasto
                'credit_account_id' => $caja, // Disminuye Caja
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
            [
                'operation_code' => 'FALTANTE_CAJA',
                'name' => 'Faltante de Caja',
                'debit_account_id' => $getAccount('5104'), // Aumenta Gasto por Faltante
                'credit_account_id' => $caja, // Disminuye Caja General
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
            [
                'operation_code' => 'SOBRANTE_CAJA',
                'name' => 'Sobrante de Caja',
                'debit_account_id' => $caja, // Aumenta Caja General
                'credit_account_id' => $getAccount('4106'), // Aumenta Ingreso por Sobrante
                'tax_account_id' => null,
                'tax_percentage' => 0.00,
            ],
        ];

        foreach ($operations as $op) {
            // Asegurarse de que todas las cuentas necesarias existan
            if ($op['debit_account_id'] && $op['credit_account_id']) {
                \App\Models\AccountingEngineConfig::updateOrCreate(
                    ['operation_code' => $op['operation_code']],
                    $op
                );
            }
        }
    }
}
