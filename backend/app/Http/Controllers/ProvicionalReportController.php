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
    
    public function getPdfUrlIngresos(Request $request)
    {
        $url = \Illuminate\Support\Facades\URL::temporarySignedRoute(
            'provicional-reportes-ingresos.pdf',
            now()->addMinutes(30),
            $request->only(['start_date', 'end_date', 'search'])
        );
        return response()->json(['url' => $url]);
    }

    public function getPdfUrlGastos(Request $request)
    {
        $url = \Illuminate\Support\Facades\URL::temporarySignedRoute(
            'provicional-reportes-gastos.pdf',
            now()->addMinutes(30),
            $request->only(['start_date', 'end_date', 'search'])
        );
        return response()->json(['url' => $url]);
    }

    /**
     * Download PDF Ingresos
     */
    public function exportPdfIngresos(Request $request) {
        $query = IngresoProvicional::with('user')->orderBy('fecha_ingreso', 'asc');

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
        $startDate = $request->start_date;
        $endDate = $request->end_date;
        
        $pdf = Pdf::loadView('reports.ingresos_provicional', compact('ingresos', 'startDate', 'endDate'));
        
        return $pdf->stream('reporte_ingresos.pdf');
    }


 
 /** gastos_provicional
     * Download PDF only gasto
     */
    public function exportPdfGastos(Request $request) {
    $query = GastoProvicional::with('user')->orderBy('fecha_gasto', 'asc');

    if ($request->filled('start_date')) {
        $query->whereDate('fecha_gasto', '>=', $request->start_date);
    }

    if ($request->filled('end_date')) {
        $query->whereDate('fecha_gasto', '<=', $request->end_date);
    }

    if ($request->filled('search')) {
        $searchTerm = '%' . $request->search . '%';
        $query->where('concepto', 'ilike', $searchTerm);
    }

    $gastos = $query->get();
    $startDate = $request->start_date;
    $endDate = $request->end_date;

    $pdf = Pdf::loadView('reports.gastos_provicional', compact('gastos', 'startDate', 'endDate'));

    return $pdf->stream('reporte_gastos.pdf');
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
