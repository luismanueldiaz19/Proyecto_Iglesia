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

        // Permisos
        $permissionView = Permission::firstOrCreate(['name' => 'view_reconciliations']);
        $permissionCreate = Permission::firstOrCreate(['name' => 'create_reconciliations']);
        $permissionManage = Permission::firstOrCreate(['name' => 'manage_catalog']);

        // Roles
        $adminRole = Role::firstOrCreate(['name' => 'Administrador']);
        $adminRole->givePermissionTo([$permissionView, $permissionCreate, $permissionManage]);

        $cajeraRole = Role::firstOrCreate(['name' => 'Cajera']);
        $cajeraRole->givePermissionTo([$permissionView, $permissionCreate]);
    }
}
