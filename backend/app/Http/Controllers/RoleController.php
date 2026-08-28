<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Spatie\Permission\Models\Role;

class RoleController extends Controller
{
    /**
     * Display a listing of the roles with their permissions.
     */
    public function index()
    {
        // Obtener todos los roles junto con sus permisos asignados
        $roles = Role::with('permissions')->get();

        return response()->json([
            'status' => 'success',
            'data' => $roles
        ]);
    }
}
