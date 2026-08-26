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
            now()->addMinutes(30)
        );
        return response()->json(['url' => $url]);
    }

    /**
     * Download PDF
     */
    public function exportPdf(Request $request)
    {
        $ingresos = IngresoProvicional::with('user')->orderBy('fecha_ingreso', 'desc')->get();
        $gastos = GastoProvicional::with('user')->orderBy('fecha_gasto', 'desc')->get();
        
        // Asumiendo que usas dompdf
        $pdf = Pdf::loadView('reports.provicional', compact('ingresos', 'gastos'));
        
        return $pdf->stream('reporte_provicional.pdf');
    }
    
    public function getExcelUrl(Request $request)
    {
        $url = \Illuminate\Support\Facades\URL::temporarySignedRoute(
            'provicional-reportes.excel',
            now()->addMinutes(30)
        );
        return response()->json(['url' => $url]);
    }

    /**
     * Download Excel
     */
    public function exportExcel(Request $request)
    {
        return Excel::download(new ProvicionalExport, 'reporte_provicional.xlsx');
    }
}
