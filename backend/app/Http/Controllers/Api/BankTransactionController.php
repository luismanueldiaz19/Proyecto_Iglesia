<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\BankTransaction;
use App\Models\BankAccount;

class BankTransactionController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = BankTransaction::with(['bankAccount']);

        if ($request->has('bank_account_id')) {
            $query->where('bank_account_id', $request->bank_account_id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $transactions = $query->orderBy('date', 'desc')->get();
        return response()->json($transactions);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'bank_account_id' => 'required|exists:bank_accounts,id',
            'date' => 'required|date',
            'type' => 'required|string',
            'amount' => 'required|numeric',
            'reference' => 'nullable|string',
            'description' => 'nullable|string',
            'status' => 'nullable|string',
        ]);

        $validated['status'] = $validated['status'] ?? 'pending';

        $transaction = BankTransaction::create($validated);
        
        // Update bank account balance
        $account = BankAccount::find($validated['bank_account_id']);
        $account->current_balance += $validated['amount'];
        $account->save();

        return response()->json($transaction, 201);
    }

    public function show(string $id)
    {
        $transaction = BankTransaction::with(['bankAccount'])->findOrFail($id);
        return response()->json($transaction);
    }

    public function update(Request $request, string $id)
    {
        $transaction = BankTransaction::findOrFail($id);

        $validated = $request->validate([
            'date' => 'sometimes|required|date',
            'type' => 'sometimes|required|string',
            'amount' => 'sometimes|required|numeric',
            'reference' => 'nullable|string',
            'description' => 'nullable|string',
            'status' => 'sometimes|required|string',
        ]);

        if (isset($validated['amount']) && $validated['amount'] != $transaction->amount) {
            $account = BankAccount::find($transaction->bank_account_id);
            $account->current_balance -= $transaction->amount; // revert old
            $account->current_balance += $validated['amount']; // apply new
            $account->save();
        }

        $transaction->update($validated);
        return response()->json($transaction);
    }

    public function destroy(string $id)
    {
        if (!auth()->user()->hasRole('Administrador')) {
            return response()->json(['message' => 'Acceso denegado. Solo el administrador puede eliminar registros.'], 403);
        }

        $transaction = BankTransaction::findOrFail($id);
        
        $account = BankAccount::find($transaction->bank_account_id);
        $account->current_balance -= $transaction->amount;
        $account->save();

        $transaction->delete();
        return response()->json(null, 204);
    }
}
