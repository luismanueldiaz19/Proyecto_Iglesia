<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\BankAccount;

class BankAccountController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $accounts = BankAccount::with(['bank', 'accountingAccount'])->get();
        return response()->json($accounts);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'bank_id' => 'required|exists:banks,id',
            'name' => 'required|string|max:255',
            'account_number' => 'required|string|max:255',
            'currency' => 'nullable|string|max:10',
            'current_balance' => 'numeric',
            'accounting_account_id' => 'nullable|exists:accounting_accounts,id',
            'is_active' => 'boolean',
        ]);

        $account = BankAccount::create($validated);
        return response()->json($account->load(['bank', 'accountingAccount']), 201);
    }

    public function show(string $id)
    {
        $account = BankAccount::with(['bank', 'accountingAccount'])->findOrFail($id);
        return response()->json($account);
    }

    public function update(Request $request, string $id)
    {
        $account = BankAccount::findOrFail($id);

        $validated = $request->validate([
            'bank_id' => 'sometimes|required|exists:banks,id',
            'name' => 'sometimes|required|string|max:255',
            'account_number' => 'sometimes|required|string|max:255',
            'currency' => 'nullable|string|max:10',
            'current_balance' => 'numeric',
            'accounting_account_id' => 'nullable|exists:accounting_accounts,id',
            'is_active' => 'boolean',
        ]);

        $account->update($validated);
        return response()->json($account->load(['bank', 'accountingAccount']));
    }

    public function destroy(string $id)
    {
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'Acceso denegado. Solo el administrador puede eliminar registros.'], 403);
        }

        $account = BankAccount::findOrFail($id);
        $account->delete();
        return response()->json(null, 204);
    }
}
