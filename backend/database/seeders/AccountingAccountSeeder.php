<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use  App\Models\AccountingAccount;

class AccountingAccountSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void {
        $accounts = [
            ['code' => '1000', 'name' => 'Activos', 'type' => 'Activo', 'is_transactional' => false],
            ['code' => '1100', 'name' => 'Efectivo y Equivalentes', 'type' => 'Activo', 'is_transactional' => false],
            ['code' => '1101', 'name' => 'Caja General', 'type' => 'Activo', 'is_transactional' => true],
            ['code' => '1102', 'name' => 'Bancos', 'type' => 'Activo', 'is_transactional' => true],
            ['code' => '1103', 'name' => 'Caja Chica', 'type' => 'Activo', 'is_transactional' => true],
            ['code' => '1104', 'name' => 'Inventario Librería', 'type' => 'Activo', 'is_transactional' => true],
            ['code' => '1105', 'name' => 'Inventario Cafetería', 'type' => 'Activo', 'is_transactional' => true],
            ['code' => '2000', 'name' => 'Pasivos', 'type' => 'Pasivo', 'is_transactional' => false],
            ['code' => '2100', 'name' => 'Cuentas por Pagar', 'type' => 'Pasivo', 'is_transactional' => true],
            ['code' => '2101', 'name' => 'Préstamos por Pagar', 'type' => 'Pasivo', 'is_transactional' => true],
            ['code' => '2102', 'name' => 'ITBIS por Pagar', 'type' => 'Pasivo', 'is_transactional' => true],
            ['code' => '3000', 'name' => 'Capital', 'type' => 'Capital', 'is_transactional' => false],
            ['code' => '3100', 'name' => 'Fondo Institucional', 'type' => 'Capital', 'is_transactional' => true],
            ['code' => '4000', 'name' => 'Ingresos', 'type' => 'Ingreso', 'is_transactional' => false],
            ['code' => '4100', 'name' => 'Diezmos', 'type' => 'Ingreso', 'is_transactional' => true],
            ['code' => '4101', 'name' => 'Ofrendas', 'type' => 'Ingreso', 'is_transactional' => true],
            ['code' => '4102', 'name' => 'Ingresos Librería', 'type' => 'Ingreso', 'is_transactional' => true],
            ['code' => '4103', 'name' => 'Ingresos Cafetería', 'type' => 'Ingreso', 'is_transactional' => true],
            ['code' => '4104', 'name' => 'Donaciones Locales', 'type' => 'Ingreso', 'is_transactional' => true],
            ['code' => '4105', 'name' => 'Donaciones Extranjeras', 'type' => 'Ingreso', 'is_transactional' => true],
            ['code' => '4106', 'name' => 'Sobrante de Caja', 'type' => 'Ingreso', 'is_transactional' => true],
            ['code' => '5000', 'name' => 'Costos', 'type' => 'Costo', 'is_transactional' => false],
            ['code' => '5100', 'name' => 'Costo de Ventas Librería', 'type' => 'Costo', 'is_transactional' => true],
            ['code' => '5101', 'name' => 'Costo de Ventas Cafetería', 'type' => 'Costo', 'is_transactional' => true],
            ['code' => '6000', 'name' => 'Gastos', 'type' => 'Gasto', 'is_transactional' => false],
            ['code' => '6100', 'name' => 'Gastos Operativos', 'type' => 'Gasto', 'is_transactional' => true],
            ['code' => '6101', 'name' => 'Gastos de Mantenimiento', 'type' => 'Gasto', 'is_transactional' => true],
            ['code' => '6102', 'name' => 'Pago de Nómina', 'type' => 'Gasto', 'is_transactional' => true],
            ['code' => '6103', 'name' => 'Servicios Públicos (Agua, Luz, etc.)', 'type' => 'Gasto', 'is_transactional' => true],
            ['code' => '6104', 'name' => 'Faltante de Caja', 'type' => 'Gasto', 'is_transactional' => true],
            ['code' => '6105', 'name' => 'Gastos Legales y Jurídicos', 'type' => 'Gasto', 'is_transactional' => true],
        ];

        foreach ($accounts as $account) {
            AccountingAccount::updateOrCreate(
                ['code' => $account['code']],
                $account
            );
        }
    }
}
