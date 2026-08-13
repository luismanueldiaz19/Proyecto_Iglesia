<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use App\Imports\IngresoProvicionalImport;
use App\Models\IngresoProvicional;

class IngresoProvicionalController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = IngresoProvicional::with('user')->orderBy('fecha_ingreso', 'desc');

        if ($request->filled('start_date')) {
            $query->whereDate('fecha_ingreso', '>=', $request->start_date);
        }

        if ($request->filled('end_date')) {
            $query->whereDate('fecha_ingreso', '<=', $request->end_date);
        }
        
        if ($request->filled('search')) {
            $searchTerm = '%' . $request->search . '%';
            $query->where('concepto', 'ilike', $searchTerm);
        }

        $ingresos = $query->get();

        return response()->json($ingresos);
    }

    public function chartData()
    {
        $year = date('Y');
        
        $data = IngresoProvicional::selectRaw("TO_CHAR(fecha_ingreso, 'MM') as mes, SUM(monto) as total")
            ->whereYear('fecha_ingreso', $year)
            ->groupBy('mes')
            ->orderBy('mes')
            ->get();
            
        return response()->json($data);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request) {
        $validated = $request->validate([
            'fecha_ingreso' => 'required|date',
            'concepto' => 'required|string|max:255',
            'monto' => 'required|numeric|min:0.01',
            'bank_account_id' => 'required|exists:bank_accounts,id',
        ]);

        // Aseguramos que se registra el usuario autenticado
        $validated['usuario_registro'] = $request->user()->id;

        $bankAccountId = $validated['bank_account_id'];
        unset($validated['bank_account_id']);

        $ingreso = IngresoProvicional::create($validated);

        // Crear la transacción bancaria (Depósito Pendiente)
        \App\Models\BankTransaction::create([
            'bank_account_id' => $bankAccountId,
            'date' => $ingreso->fecha_ingreso,
            'type' => 'deposit',
            'amount' => $ingreso->monto,
            'reference' => 'ING-' . $ingreso->id,
            'description' => $ingreso->concepto,
            'status' => 'transit',
        ]);

        // Actualizar el balance actual de la cuenta bancaria / caja
        $bankAccount = \App\Models\BankAccount::find($bankAccountId);
        if ($bankAccount) {
            $bankAccount->current_balance += $ingreso->monto;
            $bankAccount->save();
        }

        return response()->json($ingreso, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $ingreso = IngresoProvicional::with('user')->findOrFail($id);
        return response()->json($ingreso);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $ingreso = IngresoProvicional::findOrFail($id);

        $validated = $request->validate([
            'fecha_ingreso' => 'sometimes|required|date',
            'concepto' => 'sometimes|required|string|max:255',
            'monto' => 'sometimes|required|numeric|min:0.01',
        ]);

        $ingreso->update($validated);

        return response()->json($ingreso);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $ingreso = IngresoProvicional::findOrFail($id);
        $ingreso->delete();

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
            Excel::import(new IngresoProvicionalImport($request->user()->id, $request->bank_account_id), $request->file('file'));
            return response()->json(['message' => 'Importación exitosa'], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error en la importaciA3n: ' . $e->getMessage()], 400);
        }
    }

    public function previewImportExcel(Request $request)
    {
        $request->validate([
            'file' => 'required|mimes:xlsx,xls,csv|max:10240',
        ]);
        
        try {
            $import = new \App\Imports\PreviewIngresoProvicionalImport();
            \Maatwebsite\Excel\Facades\Excel::import($import, $request->file('file'));
            
            return response()->json([
                'data' => $import->parsedData,
                'total' => $import->totalAmount
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error en la lectura: ' . $e->getMessage()], 400);
        }
    }
}
