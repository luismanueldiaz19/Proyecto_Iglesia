<?php

namespace App\Http\Controllers;

use App\Models\AccountingAccount;
use Illuminate\Http\Request;

class AccountingAccountController extends Controller
{
    /**
     * List all accounting accounts.
     */
    public function index()
    {
        $accounts = AccountingAccount::with('parent')->orderBy('code')->get();
        return response()->json($accounts);
    }

    /**
     * Store a newly created accounting account.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string|unique:accounting_accounts,code',
            'name' => 'required|string|max:255',
            'type' => 'required|in:Activo,Pasivo,Capital,Ingreso,Gasto',
            'parent_id' => 'nullable|exists:accounting_accounts,id',
            'is_transactional' => 'boolean',
        ]);

        // Validación de estándares contables (Prefijos)
        $code = $validated['code'];
        $type = $validated['type'];
        $isValidPrefix = match($type) {
            'Activo' => str_starts_with($code, '1'),
            'Pasivo' => str_starts_with($code, '2'),
            'Capital' => str_starts_with($code, '3'),
            'Ingreso' => str_starts_with($code, '4'),
            'Gasto' => str_starts_with($code, '5'),
            default => false,
        };

        if (!$isValidPrefix) {
            return response()->json([
                'message' => 'El código de la cuenta no coincide con el tipo seleccionado (ej. Activos deben iniciar con 1).',
            ], 422);
        }

        // Default to true if not provided
        $validated['is_transactional'] = $validated['is_transactional'] ?? true;

        $account = AccountingAccount::create($validated);

        return response()->json($account, 201);
    }

    /**
     * Remove the specified accounting account.
     */
    public function destroy(Request $request, $id)
    {
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'Acceso denegado. Solo el administrador puede eliminar registros.'], 403);
        }

        if (!$request->user()->hasRole('Administrador') && !$request->user()->hasRole('admin')) {
            return response()->json(['message' => 'Solo los administradores pueden eliminar cuentas.'], 403);
        }

        $account = AccountingAccount::find($id);
        
        if (!$account) {
            return response()->json(['message' => 'Cuenta no encontrada.'], 404);
        }

        $baseCodes = ['1000', '2000', '3000', '4000', '5000'];
        if (in_array($account->code, $baseCodes)) {
            return response()->json(['message' => 'No se pueden eliminar las cuentas base primarias.'], 403);
        }

        if ($account->children()->count() > 0) {
            return response()->json(['message' => 'No se puede eliminar una cuenta que tiene subcuentas.'], 400);
        }

        // Si tuvieras transacciones podrías validar aquí que no tenga movimientos
        // if ($account->transactions()->count() > 0) { ... }

        $account->delete();
        
        return response()->json(['message' => 'Cuenta eliminada exitosamente.']);
    }
}
