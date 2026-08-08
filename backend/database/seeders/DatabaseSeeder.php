<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Module;
use App\Models\Denomination;
use App\Models\AccountingAccount;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void {
        $this->call([
            RolesAndPermissionsSeeder::class,
            UserSeeder::class,
            ModuleSeeder::class,
            DenominationSeeder::class,
            AccountingAccountSeeder::class,
            AccountingEngineConfigSeeder::class,
            BankSeeder::class,
            BankAccountSeeder::class,
        ]);
    }
}
