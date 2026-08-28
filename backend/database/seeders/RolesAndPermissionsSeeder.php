<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void {
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        // 1. Crear Permisos (CRUD general)
        $viewRecords = Permission::firstOrCreate(['name' => 'view_records']);
        $createRecords = Permission::firstOrCreate(['name' => 'create_records']);
        $updateRecords = Permission::firstOrCreate(['name' => 'update_records']);
        $deleteRecords = Permission::firstOrCreate(['name' => 'delete_records']);

        // 2. Crear Roles y Asignar Permisos

        // A. Administrador: No necesita permisos explícitos aquí si usamos Gate::before, 
        // pero podemos crear el rol vacío o con todos. Lo dejamos creado.
        Role::firstOrCreate(['name' => 'Administrador']);

        // B. Gerente: Solo lectura (Reportes, Movimientos, Info)
        $gerenteRole = Role::firstOrCreate(['name' => 'Gerente']);
        $gerenteRole->syncPermissions([$viewRecords]);

        // C. Supervisor: Solo registros y actualizar (No borrar)
        $supervisorRole = Role::firstOrCreate(['name' => 'Supervisor']);
        $supervisorRole->syncPermissions([$viewRecords, $createRecords, $updateRecords]);

        // D. Operativo (Reemplaza a Cajera): Solo registros
        $operativoRole = Role::firstOrCreate(['name' => 'Operativo']);
        $operativoRole->syncPermissions([$viewRecords, $createRecords]);
    }
}
