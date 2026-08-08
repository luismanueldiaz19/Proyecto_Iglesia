<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\GastoProvicionalImport;

class GastoProvicionalController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = \App\Models\GastoProvicional::with('user')->orderBy('fecha_gasto', 'desc');

        if ($request->filled('start_date')) {
            $query->whereDate('fecha_gasto', '>=', $request->start_date);
        }

        if ($request->filled('end_date')) {
            $query->whereDate('fecha_gasto', '<=', $request->end_date);
        }
        
        if ($request->filled('search')) {
            $searchTerm = '%' . $request->search . '%';
            $query->where(function ($q) use ($searchTerm) {
                $q->where('concepto', 'ilike', $searchTerm)
                  ->orWhere('num_check', 'ilike', $searchTerm);
            });
        }

        $gastos = $query->get();
        return response()->json($gastos);
    }

    public function chartData()
    {
        $year = date('Y');
        
        $data = \App\Models\GastoProvicional::selectRaw(
                "TO_CHAR(fecha_gasto, 'MM') as mes, SUM(monto) as total, COUNT(DISTINCT NULLIF(TRIM(num_check), '')) as num_checks"
            )
            ->whereYear('fecha_gasto', $year)
            ->groupBy('mes')
            ->orderBy('mes')
            ->get();
            
        return response()->json($data);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'fecha_gasto' => 'required|date',
            'concepto' => 'required|string|max:255',
            'num_check' => 'nullable|string|max:255',
            'monto' => 'required|numeric|min:0.01',
            'bank_account_id' => 'required|exists:bank_accounts,id',
        ]);

        $validated['usuario_registro'] = $request->user()->id;

        $bankAccountId = $validated['bank_account_id'];
        unset($validated['bank_account_id']);

        $gasto = \App\Models\GastoProvicional::create($validated);

        // Crear la transacción bancaria (Retiro Pendiente)
        \App\Models\BankTransaction::create([
            'bank_account_id' => $bankAccountId,
            'date' => $gasto->fecha_gasto,
            'type' => 'withdrawal',
            'amount' => -$gasto->monto, // Negativo para los retiros
            'reference' => $gasto->num_check ?: 'GAS-' . $gasto->id,
            'description' => $gasto->concepto,
            'status' => 'transit',
        ]);

        // Actualizar el balance actual de la cuenta bancaria / caja
        $bankAccount = \App\Models\BankAccount::find($bankAccountId);
        if ($bankAccount) {
            $bankAccount->current_balance -= $gasto->monto;
            $bankAccount->save();
        }

        return response()->json($gasto, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $gasto = \App\Models\GastoProvicional::with('user')->findOrFail($id);
        return response()->json($gasto);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $gasto = \App\Models\GastoProvicional::findOrFail($id);

        $validated = $request->validate([
            'fecha_gasto' => 'sometimes|required|date',
            'concepto' => 'sometimes|required|string|max:255',
            'num_check' => 'nullable|string|max:255',
            'monto' => 'sometimes|required|numeric|min:0.01',
        ]);

        $gasto->update($validated);

        return response()->json($gasto);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $gasto = \App\Models\GastoProvicional::findOrFail($id);
        $gasto->delete();

        return response()->json(null, 204);
    }
    
    /**
     * Import Data from Excel.
     */
    public function importExcel(Request $request)
    {
        $request->validate([
            'file' => 'required|mimes:xlsx,xls,csv|max:10240',
            'bank_account_id' => 'required|exists:bank_accounts,id',
        ]);
        
        try {
            Excel::import(new GastoProvicionalImport($request->user()->id, $request->bank_account_id), $request->file('file'));
            return response()->json(['message' => 'Importación exitosa'], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error en la importación: ' . $e->getMessage()], 400);
        }
    }
}
