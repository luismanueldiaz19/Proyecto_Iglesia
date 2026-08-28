<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\BankReconciliation;

class BankReconciliationController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = BankReconciliation::with(['bankAccount', 'reconciledBy']);

        if ($request->has('bank_account_id')) {
            $query->where('bank_account_id', $request->bank_account_id);
        }

        $reconciliations = $query->orderBy('statement_date', 'desc')->get();
        return response()->json($reconciliations);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'bank_account_id' => 'required|exists:bank_accounts,id',
            'statement_date' => 'required|date',
            'statement_balance' => 'required|numeric',
            'notes' => 'nullable|string',
        ]);

        $validated['status'] = 'draft';
        $validated['reconciled_by'] = $request->user()->id ?? null;

        $reconciliation = BankReconciliation::create($validated);
        return response()->json($reconciliation, 201);
    }

    public function show(string $id)
    {
        $reconciliation = BankReconciliation::with(['bankAccount', 'reconciledBy', 'transactions'])->findOrFail($id);
        return response()->json($reconciliation);
    }

    public function update(Request $request, string $id)
    {
        $reconciliation = BankReconciliation::findOrFail($id);

        $validated = $request->validate([
            'statement_balance' => 'sometimes|required|numeric',
            'notes' => 'nullable|string',
            'status' => 'sometimes|required|in:draft,completed',
            'transaction_ids' => 'sometimes|array',
            'transaction_ids.*' => 'exists:bank_transactions,id'
        ]);

        $reconciliation->update($validated);

        if ($request->has('transaction_ids')) {
            $reconciliation->transactions()->sync($request->transaction_ids);
        }

        if (isset($validated['status']) && $validated['status'] == 'completed') {
            // Reconcile all attached transactions after syncing
            foreach($reconciliation->transactions()->get() as $transaction) {
                $transaction->status = 'reconciled';
                $transaction->save();
            }
        }

        return response()->json($reconciliation->load('transactions'));
    }

    public function destroy(string $id)
    {
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'Acceso denegado. Solo el administrador puede eliminar registros.'], 403);
        }

        $reconciliation = BankReconciliation::findOrFail($id);
        $reconciliation->delete();
        return response()->json(null, 204);
    }
}
