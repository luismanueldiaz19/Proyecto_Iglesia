<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\BankAccount;
use Illuminate\Support\Facades\URL;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use App\Models\BankTransaction;

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

    public function getStatementPdfUrl(Request $request, string $id)
    {
        $validated = $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $url = URL::temporarySignedRoute(
            'bank-accounts.statement.pdf',
            now()->addMinutes(30),
            [
                'id' => $id,
                'start_date' => $validated['start_date'],
                'end_date' => $validated['end_date'],
            ]
        );

        return response()->json(['url' => $url]);
    }

    public function downloadStatementPdf(Request $request, string $id)
    {
        if (! $request->hasValidSignature()) {
            abort(401, 'URL inválida o expirada.');
        }

        $account = BankAccount::with(['bank'])->findOrFail($id);
        
        $startDate = Carbon::parse($request->start_date)->startOfDay();
        $endDate = Carbon::parse($request->end_date)->endOfDay();

        // Obtener transacciones en el periodo
        $transactions = BankTransaction::where('bank_account_id', $id)
            ->whereBetween('date', [$startDate, $endDate])
            ->orderBy('date', 'asc')
            ->get();

        // Calcular el balance inicial:
        // Balance actual menos suma de transacciones que ocurrieron desde el startDate hasta ahora
        $amountSinceStart = BankTransaction::where('bank_account_id', $id)
            ->where('date', '>=', $startDate)
            ->sum('amount');
            
        $initialBalance = $account->current_balance - $amountSinceStart;

        $totalDeposits = $transactions->where('amount', '>', 0)->sum('amount');
        $totalWithdrawals = $transactions->where('amount', '<', 0)->sum('amount');

        $finalBalance = $initialBalance + $totalDeposits + $totalWithdrawals;

        $data = [
            'account' => $account,
            'transactions' => $transactions,
            'startDate' => $startDate,
            'endDate' => $endDate,
            'initialBalance' => $initialBalance,
            'totalDeposits' => $totalDeposits,
            'totalWithdrawals' => abs($totalWithdrawals),
            'finalBalance' => $finalBalance,
        ];

        $pdf = Pdf::loadView('reports.bank_statement', $data);
        
        return $pdf->stream("estado_cuenta_{$account->account_number}.pdf");
    }
}
