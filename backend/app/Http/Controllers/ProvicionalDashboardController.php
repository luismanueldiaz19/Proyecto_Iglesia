<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;

class ProvicionalDashboardController extends Controller
{
    /**
     * Devuelve los datos combinados del dashboard de provisionales
     */
    public function index(Request $request)
    {
        $startDate = $request->query('start_date');
        $endDate = $request->query('end_date');

        $ingresosQuery = \App\Models\IngresoProvicional::query();
        $gastosQuery = \App\Models\GastoProvicional::query();

        if ($startDate && $endDate) {
            $ingresosQuery->whereBetween('fecha_ingreso', [$startDate, $endDate]);
            $gastosQuery->whereBetween('fecha_gasto', [$startDate, $endDate]);
        }

        $totalIngresos = (clone $ingresosQuery)->sum('monto');
        $totalGastos = (clone $gastosQuery)->sum('monto');
        $balance = $totalIngresos - $totalGastos;
        
        $ingresosPorMes = (clone $ingresosQuery)
            ->selectRaw("TO_CHAR(fecha_ingreso, 'YYYY-MM') as mes, SUM(monto) as total")
            ->groupBy('mes')
            ->get()
            ->keyBy('mes');
            
        $gastosPorMes = (clone $gastosQuery)
            ->selectRaw("TO_CHAR(fecha_gasto, 'YYYY-MM') as mes, SUM(monto) as total")
            ->groupBy('mes')
            ->get()
            ->keyBy('mes');

        $mesesSet = array_unique(array_merge($ingresosPorMes->keys()->toArray(), $gastosPorMes->keys()->toArray()));
        sort($mesesSet);

        $graficaMensual = [];
        foreach ($mesesSet as $mes) {
            $ingresoMes = isset($ingresosPorMes[$mes]) ? (float)$ingresosPorMes[$mes]->total : 0.0;
            $gastoMes = isset($gastosPorMes[$mes]) ? (float)$gastosPorMes[$mes]->total : 0.0;
            $diferenciaMes = $ingresoMes - $gastoMes;
            
            $graficaMensual[] = [
                'mes' => $mes,
                'ingresos' => $ingresoMes,
                'gastos' => $gastoMes,
                'diferencia' => $diferenciaMes,
            ];
        }

        return response()->json([
            'totales' => [
                'ingresos' => $totalIngresos,
                'gastos' => $totalGastos,
                'balance' => $balance,
            ],
            'grafica_mensual' => $graficaMensual,
        ]);
    }

    /**
     * Exporta el dashboard consolidado a PDF
     */
    public function getPdfUrl(Request $request)
    {
        $params = [];
        if ($request->has('start_date')) $params['start_date'] = $request->start_date;
        if ($request->has('end_date')) $params['end_date'] = $request->end_date;

        $url = \Illuminate\Support\Facades\URL::temporarySignedRoute(
            'provicional-dashboard.pdf',
            now()->addMinutes(30),
            $params
        );
        return response()->json(['url' => $url]);
    }

    public function exportPdf(Request $request)
    {
        $startDate = $request->query('start_date');
        $endDate = $request->query('end_date');

        $ingresosQuery = \App\Models\IngresoProvicional::query();
        $gastosQuery = \App\Models\GastoProvicional::query();

        if ($startDate && $endDate) {
            $ingresosQuery->whereBetween('fecha_ingreso', [$startDate, $endDate]);
            $gastosQuery->whereBetween('fecha_gasto', [$startDate, $endDate]);
        }

        $totalIngresos = (clone $ingresosQuery)->sum('monto');
        $totalGastos = (clone $gastosQuery)->sum('monto');
        $balance = $totalIngresos - $totalGastos;
        
        $ingresosPorMes = (clone $ingresosQuery)
            ->selectRaw("TO_CHAR(fecha_ingreso, 'YYYY-MM') as mes, SUM(monto) as total")
            ->groupBy('mes')
            ->get()
            ->keyBy('mes');
            
        $gastosPorMes = (clone $gastosQuery)
            ->selectRaw("TO_CHAR(fecha_gasto, 'YYYY-MM') as mes, SUM(monto) as total")
            ->groupBy('mes')
            ->get()
            ->keyBy('mes');

        $mesesSet = array_unique(array_merge($ingresosPorMes->keys()->toArray(), $gastosPorMes->keys()->toArray()));
        sort($mesesSet);

        $graficaMensual = [];
        foreach ($mesesSet as $mes) {
            $ingresoMes = isset($ingresosPorMes[$mes]) ? (float)$ingresosPorMes[$mes]->total : 0.0;
            $gastoMes = isset($gastosPorMes[$mes]) ? (float)$gastosPorMes[$mes]->total : 0.0;
            $diferenciaMes = $ingresoMes - $gastoMes;
            
            $graficaMensual[] = [
                'mes' => $mes,
                'ingresos' => $ingresoMes,
                'gastos' => $gastoMes,
                'diferencia' => $diferenciaMes,
            ];
        }

        $detallesIngresos = (clone $ingresosQuery)->orderBy('fecha_ingreso', 'asc')->get();
        $detallesGastos = (clone $gastosQuery)->orderBy('fecha_gasto', 'asc')->get();

        $data = [
            'fechaImpresion' => date('d/m/Y H:i:s'),
            'startDate' => $startDate,
            'endDate' => $endDate,
            'totalIngresos' => $totalIngresos,
            'totalGastos' => $totalGastos,
            'balance' => $balance,
            'datosPorMes' => $graficaMensual,
            'detallesIngresos' => $detallesIngresos,
            'detallesGastos' => $detallesGastos,
        ];

        $pdf = Pdf::loadView('pdf.dashboard_provicional', $data);
        $pdf->setPaper('a4', 'portrait');

        return $pdf->stream('dashboard_provisionales.pdf');
    }
}
