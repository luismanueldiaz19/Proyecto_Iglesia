<?php

namespace App\Http\Controllers;

use App\Models\AccountingEngineConfig;
use Illuminate\Http\Request;

class AccountingEngineConfigController extends Controller
{
    public function index()
    {
        $configs = AccountingEngineConfig::with(['debitAccount', 'creditAccount', 'taxAccount'])->get();
        return response()->json($configs);
    }

    public function store(Request $request)
    {
        if (!$request->user()->hasRole('Administrador') && !$request->user()->hasRole('admin')) {
            return response()->json(['message' => 'Solo los administradores pueden configurar operaciones.'], 403);
        }

        $validated = $request->validate([
            'operation_code' => 'required|string|unique:accounting_engine_configs,operation_code',
            'name' => 'required|string|max:255',
            'debit_account_id' => 'required|exists:accounting_accounts,id',
            'credit_account_id' => 'required|exists:accounting_accounts,id',
            'tax_account_id' => 'nullable|exists:accounting_accounts,id',
            'tax_percentage' => 'nullable|numeric|min:0|max:100',
        ]);

        $validated['tax_percentage'] = $validated['tax_percentage'] ?? 0;

        $config = AccountingEngineConfig::create($validated);
        
        $config->load(['debitAccount', 'creditAccount', 'taxAccount']);

        return response()->json($config, 201);
    }

    public function destroy(Request $request, $id)
    {
        if (!$request->user()->hasRole('Administrador') && !$request->user()->hasRole('admin')) {
            return response()->json(['message' => 'Solo los administradores pueden eliminar configuraciones.'], 403);
        }

        $config = AccountingEngineConfig::find($id);
        
        if (!$config) {
            return response()->json(['message' => 'Configuración no encontrada.'], 404);
        }

        $config->delete();
        
        return response()->json(['message' => 'Configuración eliminada exitosamente.']);
    }
}
