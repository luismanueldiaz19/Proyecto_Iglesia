<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Module;

class ModuleSeeder extends Seeder
{
    public function run(): void
    {
        $modules = [
            ['name' => 'Caja General', 'is_active' => true],
            ['name' => 'Intenciones', 'is_active' => true],
            ['name' => 'Ofrenda', 'is_active' => true],
            ['name' => 'Tienda', 'is_active' => true],
            ['name' => 'Cafetería', 'is_active' => true],
            ['name' => 'Donaciones', 'is_active' => true],
        ];

        foreach ($modules as $module) {
            Module::updateOrCreate(
                ['name' => $module['name']],
                $module
            );
        }
    }
}
