<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BankSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $banks = [ 
             ['name' => 'Caja/General', 'code' => 'CG'],
            ['name' => 'CoopCupadec', 'code' => 'COOPCUPADEC'],
            ['name' => 'Banco Popular Dominicano', 'code' => 'BPD'],
            ['name' => 'Banreservas', 'code' => 'BR'],
            ['name' => 'Banco BHD', 'code' => 'BHD'],
            ['name' => 'Asociación Popular de Ahorros y Préstamos (APAP)', 'code' => 'APAP'],
            ['name' => 'Banco Santa Cruz', 'code' => 'BSC'],
            ['name' => 'Scotiabank', 'code' => 'BNS'],
            ['name' => 'Promerica', 'code' => 'PRO'],
            ['name' => 'Asociación Cibao', 'code' => 'ACAP'],
        ];

        foreach ($banks as $bank) {
            DB::table('banks')->insert([
                'name' => $bank['name'],
                'code' => $bank['code'],
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
