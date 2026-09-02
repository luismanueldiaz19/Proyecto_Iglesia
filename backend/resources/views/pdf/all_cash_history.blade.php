<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Historial de Cuadres</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #111827;
            font-size: 14px;
            margin: 0;
            padding: 20px;
        }
        .report-card {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            width: 100%;
            margin: 0 auto;
        }
        .header-table {
            width: 100%;
            background-color: #0B2E6B;
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
            border-collapse: collapse;
        }
        .header-table td {
            padding: 28px 32px;
            vertical-align: middle;
        }
        .header-title-small {
            margin: 0;
            font-size: 11px;
            letter-spacing: 1.5px;
            color: #B7CFC3;
            text-transform: uppercase;
        }
        .header-title-large {
            margin: 2px 0 0;
            font-size: 20px;
            font-weight: bold;
            color: #FFFFFF;
        }
        .header-receipt-text {
            margin: 0;
            font-size: 11px;
            color: #B7CFC3;
            text-align: right;
        }
        .header-receipt-number {
            margin: 2px 0 0;
            font-size: 14px;
            font-weight: normal;
            color: #D4A017;
            text-align: right;
        }
        .body-section {
            padding: 24px 32px 32px 32px;
        }
        .title-table {
            width: 100%;
            border-collapse: collapse;
            border-bottom: 1px solid #e5e7eb;
            margin-bottom: 20px;
        }
        .title-table td {
            padding-bottom: 16px;
            vertical-align: bottom;
        }
        .title-text {
            margin: 0;
            font-size: 20px;
            font-weight: bold;
            color: #111827;
            text-transform: uppercase;
        }
        .date-text {
            font-size: 12px;
            color: #6b7280;
            text-align: right;
        }
        
        table.data-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            font-size: 10px;
        }
        table.data-table th, table.data-table td {
            border: 1px solid #E5E7EB;
            padding: 4px 6px;
            text-align: left;
        }
        table.data-table th {
            background-color: #F9FAFB;
            color: #374151;
            font-weight: bold;
        }
        table.data-table .right {
            text-align: right;
        }
        table.data-table .center {
            text-align: center;
        }
        
        .status-perfect { color: #10B981; font-weight: bold; }
        .status-faltante { color: #EF4444; font-weight: bold; }
        .status-sobrante { color: #F59E0B; font-weight: bold; }
        

        .clearfix::after {
            content: "";
            clear: both;
            display: table;
        }

        .footer-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 40px;
            border-top: 1px solid #e5e7eb;
            padding-top: 20px;
            clear: both;
        }
        .footer-table td {
            vertical-align: bottom;
            padding-top: 20px;
        }
        .signature-line {
            width: 180px;
            border-bottom: 1px solid #d1d5db;
            height: 28px;
        }
        .signature-text {
            margin: 4px 0 0;
            font-size: 11px;
            color: #6b7280;
        }
        .address-text {
            margin: 0;
            font-size: 11px;
            color: #6b7280;
            line-height: 1.5;
            text-align: right;
        }
    </style>
</head>
<body>

<div class="report-card">
    @php
        $periodoFiltro = 'Desde <b>' . ($request->start_date ?? 'Inicio') . '</b> <br> Hasta <b>' . ($request->end_date ?? 'Hoy') . '</b>';
        if ($request->module_id && $request->module_id !== 'null') {
            $periodoFiltro .= '<br>Módulo ID: ' . $request->module_id;
        }
    @endphp
    @include('pdf.components.header', ['title' => 'Historial de Cuadres', 'period' => $periodoFiltro])

    <div class="body-section">

    @php
        $totalFisico = 0;
        $totalGastos = 0;
        $totalADepositar = 0;
        $totalDepositado = 0;
        $totalDiferencia = 0;
    @endphp

    <table class="data-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Fecha</th>
                <th>Módulo</th>
                <th class="right">Efectivo</th>
                <th class="right">Gastos</th>
                <th class="right">A Depositar</th>
                <th class="right">Depósito</th>
                <th class="right">Diferencia</th>
            </tr>
        </thead>
        <tbody>
            @forelse($reconciliations as $rec)
                @php
                    $aDepositar = $rec->total_general - $rec->total_expenses;
                    $finalDiff = $rec->is_deposited 
                        ? ($rec->deposit_difference ?? $rec->difference) 
                        : $rec->difference;
                        
                    $totalFisico += $rec->total_general;
                    $totalGastos += $rec->total_expenses;
                    $totalADepositar += $aDepositar;
                    $totalDepositado += ($rec->deposit_amount ?? 0);
                    $totalDiferencia += $finalDiff;
                @endphp
                <tr>
                    <td>{{ $rec->id }}</td>
                    <td>{{ \Carbon\Carbon::parse($rec->date)->format('d/m/Y') }}</td>
                    <td>{{ $rec->module ? $rec->module->name : 'N/A' }}</td>
                    <td class="right" style="color: #10B981;">${{ number_format($rec->total_general, 2) }}</td>
                    <td class="right" style="color: #EF4444;">${{ number_format($rec->total_expenses, 2) }}</td>
                    <td class="right" style="color: #3B82F6;">${{ number_format($aDepositar, 2) }}</td>
                    <td class="right">
                        @if($rec->is_deposited)
                            <span style="color: #10B981;">${{ number_format($rec->deposit_amount ?? 0, 2) }}</span>
                        @else
                            <span style="color: #9CA3AF;">-</span>
                        @endif
                    </td>
                    <td class="right">
                        @if($finalDiff == 0)
                            <span class="status-perfect">PERFECTO</span>
                        @elseif($finalDiff < 0)
                            <span class="status-faltante">FALTANTE (${{ number_format(abs($finalDiff), 2) }})</span>
                        @else
                            <span class="status-sobrante">SOBRANTE (${{ number_format($finalDiff, 2) }})</span>
                        @endif
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="8" class="center" style="color:#9ca3af;">No hay cuadres en este rango</td>
                </tr>
            @endforelse
        </tbody>
        @if($reconciliations->count() > 0)
        <tfoot>
            <tr style="background-color: #f8fafc; border-top: 2px solid #94a3b8; font-weight: bold;">
                <td colspan="3" style="text-align: right; text-transform: uppercase; color: #475569;">Totales Acumulados:</td>
                <td class="right" style="color: #10B981;">${{ number_format($totalFisico, 2) }}</td>
                <td class="right" style="color: #EF4444;">${{ number_format($totalGastos, 2) }}</td>
                <td class="right" style="color: #3B82F6;">${{ number_format($totalADepositar, 2) }}</td>
                <td class="right" style="color: #10B981;">${{ number_format($totalDepositado, 2) }}</td>
                <td class="right">
                    @if($totalDiferencia == 0)
                        <span style="color: #10B981;">$0.00</span>
                    @elseif($totalDiferencia < 0)
                        <span style="color: #EF4444;">-${{ number_format(abs($totalDiferencia), 2) }}</span>
                    @else
                        <span style="color: #F59E0B;">+${{ number_format($totalDiferencia, 2) }}</span>
                    @endif
                </td>
            </tr>
        </tfoot>
        @endif
    </table>

        @include('pdf.components.footer')
    </div> <!-- end body section -->
</div> <!-- end report card -->

</body>
</html>
