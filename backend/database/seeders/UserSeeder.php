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
            ['username' => 'ludeveloper'],
            [
                'name' => 'Luis Manuel',
                'password' => bcrypt('199512'),
            ]
        );
        $admin->assignRole('Administrador');

        $operativo = User::firstOrCreate(
            ['username' => 'operativo1'],
            [
                'name' => 'Operativo 1',
                'password' => bcrypt('123456'),
            ]
        );
        $operativo->assignRole('Operativo');

        $gerente = User::firstOrCreate(
            ['username' => 'gerente1'],
            [
                'name' => 'Gerente',
                'password' => bcrypt('123456'),
            ]
        );
        $gerente->assignRole('Gerente');

        $supervisor = User::firstOrCreate(
            ['username' => 'supervisor1'],
            [
                'name' => 'Supervisor',
                'password' => bcrypt('123456'),
            ]
        );
        $supervisor->assignRole('Supervisor');

        $operativo2 = User::firstOrCreate(
            ['username' => 'operativo2'],
            [
                'name' => 'Operativo 2',
                'password' => bcrypt('123456'),
            ]
        );
        $operativo2->assignRole('Operativo');
    }
}
