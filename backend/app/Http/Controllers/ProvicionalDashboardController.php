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

        $totalIngresosNetos = (clone $ingresosQuery)->sum('monto');
        $totalGastos = (clone $gastosQuery)->sum('monto');
        $totalIngresosBrutos = $totalIngresosNetos + $totalGastos;
        
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
            $ingresoNetoMes = isset($ingresosPorMes[$mes]) ? (float)$ingresosPorMes[$mes]->total : 0.0;
            $gastoMes = isset($gastosPorMes[$mes]) ? (float)$gastosPorMes[$mes]->total : 0.0;
            $ingresoBrutoMes = $ingresoNetoMes + $gastoMes;
            
            $graficaMensual[] = [
                'mes' => $mes,
                'ingresos' => $ingresoBrutoMes,
                'gastos' => $gastoMes,
                'diferencia' => $ingresoNetoMes,
            ];
        }

        return response()->json([
            'totales' => [
                'ingresos' => $totalIngresosBrutos,
                'gastos' => $totalGastos,
                'balance' => $totalIngresosNetos,
            ],
            'grafica_mensual' => $graficaMensual,
        ]);
    }

    /**
     * Exporta el dashboard consolidado a PDF
     */
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

        $totalIngresosNetos = (clone $ingresosQuery)->sum('monto');
        $totalGastos = (clone $gastosQuery)->sum('monto');
        $totalIngresosBrutos = $totalIngresosNetos + $totalGastos;
        
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
            $ingresoNetoMes = isset($ingresosPorMes[$mes]) ? (float)$ingresosPorMes[$mes]->total : 0.0;
            $gastoMes = isset($gastosPorMes[$mes]) ? (float)$gastosPorMes[$mes]->total : 0.0;
            $ingresoBrutoMes = $ingresoNetoMes + $gastoMes;
            
            $graficaMensual[] = [
                'mes' => $mes,
                'ingresos' => $ingresoBrutoMes,
                'gastos' => $gastoMes,
                'diferencia' => $ingresoNetoMes,
            ];
        }

        $data = [
            'fechaImpresion' => date('d/m/Y H:i:s'),
            'startDate' => $startDate,
            'endDate' => $endDate,
            'totalIngresos' => $totalIngresosBrutos,
            'totalGastos' => $totalGastos,
            'balance' => $totalIngresosNetos,
            'datosPorMes' => $graficaMensual,
        ];

        $pdf = Pdf::loadView('pdf.dashboard_provicional', $data);
        $pdf->setPaper('a4', 'portrait');

        return $pdf->download('dashboard_provisionales.pdf');
    }
}
