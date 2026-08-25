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
        
        if ($reconciliation->status !== 'draft' && !$request->user()->hasRole('Administrador')) {
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

        $this->recalculateReconciliation($reconciliation);

        return response()->json($transaction, 201);
    }
    public function update(Request $request, $id)
    {
        $request->validate([
            'account_id' => 'required|exists:accounting_accounts,id',
            'amount' => 'required|numeric|min:0.01',
            'type' => 'required|in:income,expense',
            'description' => 'required|string|max:255',
        ]);

        $transaction = CashTransaction::findOrFail($id);
        $reconciliation = CashReconciliation::findOrFail($transaction->cash_reconciliation_id);

        if ($reconciliation->status !== 'draft' && !$request->user()->hasRole('Administrador')) {
            return response()->json(['error' => 'No se pueden editar transacciones de una caja cerrada.'], 400);
        }

        $transaction->update([
            'account_id' => $request->account_id,
            'amount' => $request->amount,
            'type' => $request->type,
            'description' => $request->description,
        ]);

        try {
            // Delete old accounting entry
            $oldEntry = \App\Models\JournalEntry::where('reference_id', $transaction->id)
                ->where('reference_type', CashTransaction::class)
                ->first();
            
            if ($oldEntry) {
                \App\Models\JournalEntryLine::where('journal_entry_id', $oldEntry->id)->delete();
                $oldEntry->delete();
            }

            // Create new accounting entry
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
            Log::error("Error contable al actualizar transacción: " . $e->getMessage());
        }

        $this->recalculateReconciliation($reconciliation);

        return response()->json($transaction, 200);
    }


    private function recalculateReconciliation(CashReconciliation $reconciliation)
    {
        $transactions = $reconciliation->transactions()->get();
        $theoreticalIncome = $transactions->where('type', 'income')->sum('amount');
        $theoreticalExpense = $transactions->where('type', 'expense')->sum('amount');
        $theoreticalTotal = $theoreticalIncome - $theoreticalExpense;
        
        $updateData = [
            'total_expenses' => $theoreticalExpense,
        ];

        if ($reconciliation->status === 'closed') {
            $physicalTotal = $reconciliation->total_general;
            $difference = $physicalTotal - $theoreticalTotal;
            $updateData['difference'] = $difference;
        }

        $reconciliation->update($updateData);
    }
}
