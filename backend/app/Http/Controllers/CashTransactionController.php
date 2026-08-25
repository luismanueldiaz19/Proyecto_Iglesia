<?php

namespace App\Http\Controllers;

use App\Models\CashTransaction;
use App\Models\CashReconciliation;
use App\Models\GastoProvicional;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Services\AccountingEngineService;

class CashTransactionController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'cash_reconciliation_id' => 'required|exists:cash_reconciliations,id',
            'account_id'             => 'required|exists:accounting_accounts,id',
            'amount'                 => 'required|numeric|min:0.01',
            'type'                   => 'required|in:income,expense',
            'description'            => 'required|string|max:255',
        ]);

        $reconciliation = CashReconciliation::findOrFail($request->cash_reconciliation_id);

        if ($reconciliation->status !== 'draft' && !$request->user()->hasRole('Administrador')) {
            return response()->json(['error' => 'No se pueden añadir transacciones a una caja cerrada.'], 400);
        }

        // DB::transaction garantiza atomicidad:
        // Si falla CashTransaction o GastoProvicional → todo hace rollback.
        $transaction = DB::transaction(function () use ($request, $reconciliation) {

            // 1. Registrar la transacción de caja (comportamiento original)
            $transaction = CashTransaction::create([
                'cash_reconciliation_id' => $reconciliation->id,
                'account_id'             => $request->account_id,
                'amount'                 => $request->amount,
                'type'                   => $request->type,
                'description'            => $request->description,
            ]);

            // 2. Si es un gasto, crear el gasto provicional vinculado al cuadre.
            //    IMPORTANTE: NO se crea BankTransaction ni se modifica current_balance,
            //    ya que este efectivo nunca pasó por la cuenta bancaria.
            if ($request->type === 'expense') {
                GastoProvicional::create([
                    'fecha_gasto'         => $reconciliation->date,
                    'concepto'            => $request->description,
                    'num_check'           => null,   // Gastos de cuadre no tienen cheque
                    'monto'               => $request->amount,
                    'usuario_registro'    => $request->user()->id,
                    'cash_transaction_id' => $transaction->id,
                    'origen'              => 'cuadre',
                ]);
            }

            // 3. Asiento contable (fuera del try/catch para que también haga rollback si falla)
            try {
                $cajaGeneralAccountId = 3;
                $accounting = app(AccountingEngineService::class);

                if ($request->type === 'income') {
                    $lines = [
                        ['account_id' => $cajaGeneralAccountId, 'debit' => $request->amount, 'credit' => 0],
                        ['account_id' => $request->account_id,  'debit' => 0, 'credit' => $request->amount],
                    ];
                } else {
                    $lines = [
                        ['account_id' => $request->account_id,  'debit' => $request->amount, 'credit' => 0],
                        ['account_id' => $cajaGeneralAccountId, 'debit' => 0, 'credit' => $request->amount],
                    ];
                }

                $accounting->recordManualEntry(
                    description:   'Transacción de Caja: ' . $request->description,
                    lines:         $lines,
                    referenceId:   $transaction->id,
                    referenceType: CashTransaction::class
                );
            } catch (\Exception $e) {
                // El error contable se loguea pero NO interrumpe la transacción principal
                Log::error('Error contable al registrar transacción de cuadre: ' . $e->getMessage());
            }

            return $transaction;
        });

        $this->recalculateReconciliation($reconciliation);

        return response()->json($transaction, 201);
    }
    public function update(Request $request, $id)
    {
        $request->validate([
            'account_id'  => 'required|exists:accounting_accounts,id',
            'amount'      => 'required|numeric|min:0.01',
            'type'        => 'required|in:income,expense',
            'description' => 'required|string|max:255',
        ]);

        $transaction    = CashTransaction::findOrFail($id);
        $reconciliation = CashReconciliation::findOrFail($transaction->cash_reconciliation_id);

        if ($reconciliation->status !== 'draft' && !$request->user()->hasRole('Administrador')) {
            return response()->json(['error' => 'No se pueden editar transacciones de una caja cerrada.'], 400);
        }

        // DB::transaction garantiza atomicidad:
        // Si falla la actualización de cash_transactions o gasto_provicionals → rollback.
        DB::transaction(function () use ($request, $transaction) {

            // 1. Actualizar la transacción de caja
            $transaction->update([
                'account_id'  => $request->account_id,
                'amount'      => $request->amount,
                'type'        => $request->type,
                'description' => $request->description,
            ]);

            // 2. Si existe un gasto provicional vinculado (origen = 'cuadre'), sincronizarlo.
            //    El monto y el concepto deben reflejar siempre el valor del cuadre.
            //    SIN modificar banco (no se toca BankTransaction ni current_balance).
            $gastoVinculado = GastoProvicional::where('cash_transaction_id', $transaction->id)
                ->where('origen', 'cuadre')
                ->first();

            if ($gastoVinculado) {
                if ($request->type === 'expense') {
                    // Actualizamos monto y concepto para mantener consistencia
                    $gastoVinculado->update([
                        'monto'   => $request->amount,
                        'concepto' => $request->description,
                    ]);
                } else {
                    // Si el tipo cambió de expense → income, el gasto provicional
                    // ya no tiene sentido: lo eliminamos para mantener integridad.
                    $gastoVinculado->delete();
                }
            } elseif ($request->type === 'expense') {
                // Caso borde: si no existe el gasto provicional vinculado (ej. registros
                // anteriores a esta funcionalidad), lo creamos ahora para sincronizar.
                $reconciliation = CashReconciliation::find($transaction->cash_reconciliation_id);
                if ($reconciliation) {
                    GastoProvicional::create([
                        'fecha_gasto'         => $reconciliation->date,
                        'concepto'            => $request->description,
                        'num_check'           => null,
                        'monto'               => $request->amount,
                        'usuario_registro'    => $request->user()->id,
                        'cash_transaction_id' => $transaction->id,
                        'origen'              => 'cuadre',
                    ]);
                }
            }

            // 3. Actualizar asiento contable
            try {
                $oldEntry = \App\Models\JournalEntry::where('reference_id', $transaction->id)
                    ->where('reference_type', CashTransaction::class)
                    ->first();

                if ($oldEntry) {
                    \App\Models\JournalEntryLine::where('journal_entry_id', $oldEntry->id)->delete();
                    $oldEntry->delete();
                }

                $cajaGeneralAccountId = 3;
                $accounting = app(AccountingEngineService::class);

                if ($request->type === 'income') {
                    $lines = [
                        ['account_id' => $cajaGeneralAccountId, 'debit' => $request->amount, 'credit' => 0],
                        ['account_id' => $request->account_id,  'debit' => 0, 'credit' => $request->amount],
                    ];
                } else {
                    $lines = [
                        ['account_id' => $request->account_id,  'debit' => $request->amount, 'credit' => 0],
                        ['account_id' => $cajaGeneralAccountId, 'debit' => 0, 'credit' => $request->amount],
                    ];
                }

                $accounting->recordManualEntry(
                    description:   'Transacción de Caja: ' . $request->description,
                    lines:         $lines,
                    referenceId:   $transaction->id,
                    referenceType: CashTransaction::class
                );
            } catch (\Exception $e) {
                Log::error('Error contable al actualizar transacción de cuadre: ' . $e->getMessage());
            }
        });

        $this->recalculateReconciliation($reconciliation);

        return response()->json($transaction->fresh(), 200);
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
