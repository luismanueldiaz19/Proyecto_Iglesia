<?php

namespace App\Http\Controllers;

use App\Models\CashTransaction;
use App\Models\CashReconciliation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Services\AccountingEngineService;

class CashTransactionController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'cash_reconciliation_id' => 'required|exists:cash_reconciliations,id',
            'account_id' => 'required|exists:accounting_accounts,id',
            'amount' => 'required|numeric|min:0.01',
            'type' => 'required|in:income,expense',
            'description' => 'required|string|max:255',
        ]);

        $reconciliation = CashReconciliation::findOrFail($request->cash_reconciliation_id);
        
        if ($reconciliation->status !== 'draft') {
            return response()->json(['error' => 'No se pueden añadir transacciones a una caja cerrada.'], 400);
        }

        $transaction = CashTransaction::create([
            'cash_reconciliation_id' => $reconciliation->id,
            'account_id' => $request->account_id,
            'amount' => $request->amount,
            'type' => $request->type,
            'description' => $request->description,
        ]);

        try {
            $cajaGeneralAccountId = 3;
            $accounting = app(AccountingEngineService::class);
            
            if ($request->type === 'income') {
                $lines = [
                    ['account_id' => $cajaGeneralAccountId, 'debit' => $request->amount, 'credit' => 0],
                    ['account_id' => $request->account_id, 'debit' => 0, 'credit' => $request->amount]
                ];
            } else {
                $lines = [
                    ['account_id' => $request->account_id, 'debit' => $request->amount, 'credit' => 0],
                    ['account_id' => $cajaGeneralAccountId, 'debit' => 0, 'credit' => $request->amount]
                ];
            }
            
            $accounting->recordManualEntry(
                description: "Transacción de Caja: " . $request->description,
                lines: $lines,
                referenceId: $transaction->id,
                referenceType: CashTransaction::class
            );
        } catch (\Exception $e) {
            Log::error("Error contable al registrar transacción: " . $e->getMessage());
        }

        return response()->json($transaction, 201);
    }
}
