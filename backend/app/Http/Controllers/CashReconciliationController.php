<?php

namespace App\Http\Controllers;

use App\Models\CashReconciliation;
use App\Models\ReconciliationDenomination;
use App\Services\AccountingEngineService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Log;

class CashReconciliationController extends Controller
{
    public function index($moduleId)
    {
        $reconciliations = CashReconciliation::where('module_id', $moduleId)
            ->where('status', 'closed')
            ->orderBy('date', 'desc')
            ->orderBy('id', 'desc')
            ->paginate(50);

        return response()->json($reconciliations);
    }

    public function show($id)
    {
        $reconciliation = CashReconciliation::with([
            'transactions.account', 
            'denominations.denomination',
            'module'
        ])->findOrFail($id);

        return response()->json($reconciliation);
    }

    public function getPdfUrl($id)
    {
        // Genera una URL firmada válida por 30 minutos
        $url = URL::temporarySignedRoute(
            'cash-reconciliation.pdf', 
            now()->addMinutes(30), 
            ['id' => $id]
        );
        return response()->json(['url' => $url]);
    }

    public function generatePdf($id)
    {
        $reconciliation = CashReconciliation::with([
            'transactions.account', 
            'denominations.denomination',
            'module'
        ])->findOrFail($id);

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.cash_reconciliation', compact('reconciliation'));
        
        return $pdf->stream('cuadre_caja_'.$reconciliation->id.'.pdf');
    }

    public function current($moduleId)
    {
        $reconciliation = CashReconciliation::with('transactions')
            ->where('module_id', $moduleId)
            ->where('status', 'draft')
            ->first();

        if (!$reconciliation) {
            return response()->json(['message' => 'No hay caja abierta.'], 404);
        }

        return response()->json($reconciliation);
    }

    public function store(Request $request)
    {
        $request->validate([
            'module_id' => 'required|exists:modules,id',
        ]);

        $exists = CashReconciliation::where('module_id', $request->module_id)
            ->where('status', 'draft')
            ->exists();

        if ($exists) {
            return response()->json(['error' => 'Ya existe una caja abierta para este módulo.'], 400);
        }

        $reconciliation = CashReconciliation::create([
            'module_id' => $request->module_id,
            'date' => now()->toDateString(),
            'status' => 'draft',
            'user_id' => $request->user()->id,
        ]);

        return response()->json($reconciliation->load('transactions'), 201);
    }

    public function close(Request $request, $id, AccountingEngineService $accounting)
    {
        $request->validate([
            'denominations' => 'array',
            'denominations.*.id' => 'required|exists:denominations,id',
            'denominations.*.quantity' => 'required|integer|min:0',
            'denominations.*.total' => 'required|numeric|min:0',
            'total_general' => 'required|numeric|min:0',
        ]);

        return DB::transaction(function () use ($request, $id, $accounting) {
            $reconciliation = CashReconciliation::with('transactions')->findOrFail($id);
            
            if ($reconciliation->status !== 'draft') {
                return response()->json(['error' => 'Esta caja ya está cerrada.'], 400);
            }

            if ($request->has('denominations') && is_array($request->denominations)) {
                foreach ($request->denominations as $denom) {
                    ReconciliationDenomination::create([
                        'cash_reconciliation_id' => $reconciliation->id,
                        'denomination_id' => $denom['id'],
                        'quantity' => $denom['quantity'],
                        'total' => $denom['total'],
                    ]);
                }
            }

            $theoreticalIncome = $reconciliation->transactions->where('type', 'income')->sum('amount');
            $theoreticalExpense = $reconciliation->transactions->where('type', 'expense')->sum('amount');
            
            // Asumimos saldo inicial de 0 para simplicidad de esta iteración
            $theoreticalTotal = $theoreticalIncome - $theoreticalExpense;
            
            $physicalTotal = $request->total_general;
            $difference = $physicalTotal - $theoreticalTotal;

            if (abs($difference) > 0) {
                $reconciliation->update([
                    'total_local_currency' => $physicalTotal,
                    'total_general' => $physicalTotal,
                    'total_expenses' => $theoreticalExpense,
                    'difference' => $difference,
                    'status' => 'closed',
                ]);
            } else {
                 $reconciliation->update([
                    'total_local_currency' => $physicalTotal,
                    'total_general' => $physicalTotal,
                    'total_expenses' => $theoreticalExpense,
                    'difference' => $difference,
                    'status' => 'closed',
                ]);
            }

            // --- ASIENTO CONTABLE (Faltante / Sobrante) ---
            $cajaGeneralAccountId = 3;
            $sobranteAccountId = 21;
            $faltanteAccountId = 27;

            if (abs($difference) > 0) {
                $lines = [];
                if ($difference > 0) {
                    // Sobrante
                    $lines[] = ['account_id' => $cajaGeneralAccountId, 'debit' => abs($difference), 'credit' => 0];
                    $lines[] = ['account_id' => $sobranteAccountId, 'debit' => 0, 'credit' => abs($difference)];
                } else {
                    // Faltante
                    $lines[] = ['account_id' => $faltanteAccountId, 'debit' => abs($difference), 'credit' => 0];
                    $lines[] = ['account_id' => $cajaGeneralAccountId, 'debit' => 0, 'credit' => abs($difference)];
                }
                
                try {
                    $accounting->recordManualEntry(
                        description: "Ajuste de Cierre de Caja Módulo {$reconciliation->module_id} #" . $reconciliation->id,
                        lines: $lines,
                        referenceId: $reconciliation->id,
                        referenceType: CashReconciliation::class
                    );
                } catch (\Exception $e) {
                    Log::error("Error contable en cierre de caja: " . $e->getMessage());
                }
            }

            return response()->json($reconciliation);
        });
    }

    public function deposit(Request $request, $id, AccountingEngineService $accounting)
    {
        $request->validate([
            'account_id' => 'required|exists:accounting_accounts,id',
        ]);

        return DB::transaction(function () use ($request, $id, $accounting) {
            $reconciliation = CashReconciliation::findOrFail($id);

            if ($reconciliation->status !== 'closed') {
                return response()->json(['error' => 'Solo se pueden depositar cajas cerradas.'], 400);
            }

            if ($reconciliation->is_deposited) {
                return response()->json(['error' => 'Este cuadre ya fue depositado.'], 400);
            }

            $amountToDeposit = $reconciliation->total_general;
            $cajaGeneralAccountId = 3; // Caja General
            $bankAccountId = $request->account_id;

            if ($amountToDeposit > 0) {
                $lines = [
                    ['account_id' => $bankAccountId, 'debit' => $amountToDeposit, 'credit' => 0],
                    ['account_id' => $cajaGeneralAccountId, 'debit' => 0, 'credit' => $amountToDeposit],
                ];

                try {
                    $accounting->recordManualEntry(
                        description: "Depósito Bancario de Cierre de Caja Módulo {$reconciliation->module_id} #" . $reconciliation->id,
                        lines: $lines,
                        referenceId: $reconciliation->id,
                        referenceType: CashReconciliation::class
                    );
                } catch (\Exception $e) {
                    \Illuminate\Support\Facades\Log::error("Error contable en depósito de caja: " . $e->getMessage());
                }
            }

            $reconciliation->update([
                'is_deposited' => true,
                'deposit_account_id' => $bankAccountId,
                'deposit_date' => now(),
            ]);

            return response()->json($reconciliation);
        });
    }
}
