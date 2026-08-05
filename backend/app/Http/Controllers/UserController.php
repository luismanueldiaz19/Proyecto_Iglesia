<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Require Administrador role
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $users = User::with('roles')->orderBy('id', 'desc')->get();
        return response()->json($users);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users',
            'password' => 'required|string|min:6',
            'role' => 'required|string|exists:roles,name',
        ]);

        $user = User::create([
            'name' => $request->name,
            'username' => $request->username,
            'password' => Hash::make($request->password),
        ]);

        $user->assignRole($request->role);

        return response()->json([
            'message' => 'Usuario creado exitosamente',
            'user' => $user->load('roles'),
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $user = User::with('roles')->findOrFail($id);
        return response()->json($user);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $user = User::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255',
            'username' => 'required|string|max:255|unique:users,username,' . $user->id,
            'password' => 'nullable|string|min:6',
            'role' => 'required|string|exists:roles,name',
        ]);

        $user->name = $request->name;
        $user->username = $request->username;
        
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }
        
        $user->save();

        $user->syncRoles([$request->role]);

        return response()->json([
            'message' => 'Usuario actualizado exitosamente',
            'user' => $user->load('roles'),
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'No autorizado'], 403);
        }

        $user = User::findOrFail($id);

        if (auth()->id() == $user->id) {
            return response()->json([
                'message' => 'No puedes eliminar tu propio usuario.'
            ], 422);
        }

        $user->delete();

        return response()->json([
            'message' => 'Usuario eliminado exitosamente'
        ]);
    }
}
