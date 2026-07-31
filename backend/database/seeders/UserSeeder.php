<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $admin = User::firstOrCreate(
            ['username' => 'admin'],
            [
                'name' => 'Administrador',
                'password' => bcrypt('123456'),
            ]
        );
        $admin->assignRole('Administrador');

        $cajera = User::firstOrCreate(
            ['username' => 'cajera1'],
            [
                'name' => 'Cajera',
                'password' => bcrypt('123456'),
            ]
        );
        $cajera->assignRole('Cajera');
    }
}
