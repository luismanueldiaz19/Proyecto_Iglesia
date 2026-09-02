<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use Maatwebsite\Excel\Facades\Excel;
use App\Exports\ProvicionalExport;
use App\Models\IngresoProvicional;
use App\Models\GastoProvicional;
use Barryvdh\DomPDF\Facade\Pdf;


class ProvicionalReportController extends Controller
{
    /**
     * Display a listing of reports.
     */
    public function index(Request $request) {
        $ingresos = IngresoProvicional::with('user')->orderBy('fecha_ingreso', 'desc')->get();
        $gastos = GastoProvicional::with('user')->orderBy('fecha_gasto', 'desc')->get();
        return response()->json([
            'ingresos' => $ingresos,
            'gastos' => $gastos,
        ]);
    }
    
    public function getPdfUrl(Request $request)
    {
        $url = \Illuminate\Support\Facades\URL::temporarySignedRoute(
            'provicional-reportes.pdf',
            now()->addMinutes(30),
            $request->only(['start_date', 'end_date', 'search', 'type'])
        );
        return response()->json(['url' => $url]);
    }

    /**
     * Download PDF
     */
    public function exportPdf(Request $request)
    {
        $type = $request->input('type');
        $queryIngresos = IngresoProvicional::with('user')->orderBy('fecha_ingreso', 'desc');
        $queryGastos = GastoProvicional::with('user')->orderBy('fecha_gasto', 'desc');

        if ($request->filled('start_date')) {
            $queryIngresos->whereDate('fecha_ingreso', '>=', $request->start_date);
            $queryGastos->whereDate('fecha_gasto', '>=', $request->start_date);
        }

        if ($request->filled('end_date')) {
            $queryIngresos->whereDate('fecha_ingreso', '<=', $request->end_date);
            $queryGastos->whereDate('fecha_gasto', '<=', $request->end_date);
        }

        if ($request->filled('search')) {
            $searchTerm = '%' . $request->search . '%';
            $queryIngresos->where('concepto', 'ilike', $searchTerm);
            $queryGastos->where('concepto', 'ilike', $searchTerm);
        }

        $ingresos = collect();
        $gastos = collect();

        if ($type === 'ingresos' || $type === 'all' || empty($type)) {
            $ingresos = $queryIngresos->get();
        }

        if ($type === 'gastos' || $type === 'all' || empty($type)) {
            $gastos = $queryGastos->get();
        }
        
        // Asumiendo que usas dompdf
        $pdf = Pdf::loadView('reports.provicional', compact('ingresos', 'gastos', 'type'));
        
        return $pdf->stream('reporte_provicional.pdf');
    }
    
    public function getExcelUrl(Request $request)
    {
        $url = \Illuminate\Support\Facades\URL::temporarySignedRoute(
            'provicional-reportes.excel',
            now()->addMinutes(30),
            $request->only(['start_date', 'end_date', 'search', 'type'])
        );
        return response()->json(['url' => $url]);
    }

    /**
     * Download Excel
     */
    public function exportExcel(Request $request)
    {
        return Excel::download(new ProvicionalExport(
            $request->input('start_date'),
            $request->input('end_date'),
            $request->input('search'),
            $request->input('type')
        ), 'reporte_provicional.xlsx');
    }
}
