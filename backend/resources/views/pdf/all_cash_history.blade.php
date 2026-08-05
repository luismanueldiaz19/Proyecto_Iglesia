<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Historial de Cuadres</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #333;
            font-size: 14px;
            margin: 0;
            padding: 20px;
        }
        .header {
            width: 100%;
            border-bottom: 2px solid #0B2E6B;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .header-table {
            width: 100%;
            border-collapse: collapse;
        }
        .header-table td {
            vertical-align: middle;
            border: none !important;
            padding: 0 !important;
        }
        .header-logo {
            width: 100px;
            text-align: left;
        }
        .header-logo img {
            max-width: 90px;
            max-height: 90px;
            object-fit: contain;
        }
        .header-text {
            text-align: center;
        }
        .header-text h1 {
            color: #0B2E6B;
            margin: 0;
            font-size: 26px;
            font-weight: 900;
            letter-spacing: 1px;
        }
        .header-text h2 {
            color: #374151;
            margin: 4px 0 0;
            font-size: 16px;
            font-weight: bold;
        }
        .header-text p.desc {
            margin: 4px 0 0;
            color: #6B7280;
            font-size: 11px;
        }
        .header-text p.report-title {
            margin: 15px 0 0;
            color: #0B2E6B;
            font-size: 18px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        table.data-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            font-size: 12px;
        }
        table.data-table th, table.data-table td {
            border: 1px solid #E5E7EB;
            padding: 6px;
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
        
        .summary-box {
            background-color: #F9FAFB;
            border: 1px solid #E5E7EB;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
            width: 50%;
            float: right;
        }
        .summary-row {
            display: table;
            width: 100%;
            margin-bottom: 5px;
        }
        .summary-row .label {
            display: table-cell;
            text-align: left;
            font-weight: bold;
            color: #374151;
        }
        .summary-row .val {
            display: table-cell;
            text-align: right;
            font-weight: bold;
        }
        .val.total {
            font-size: 16px;
            color: #0B2E6B;
        }
        .clearfix::after {
            content: "";
            clear: both;
            display: table;
        }
    </style>
</head>
<body>

    <div class="header">
        <table class="header-table">
            <tr>
                <td class="header-logo">
                    @php
                        $logoPath = public_path('logo_app.jpeg');
                        $logoData = '';
                        if(file_exists($logoPath)) {
                            $type = pathinfo($logoPath, PATHINFO_EXTENSION);
                            $data = file_get_contents($logoPath);
                            $logoData = 'data:image/' . $type . ';base64,' . base64_encode($data);
                        }
                    @endphp
                    @if($logoData)
                        <img src="{{ $logoData }}" alt="Logo Parroquia">
                    @endif
                </td>
                <td class="header-text">
                    <h1>PARROQUIA</h1>
                    <h2>Centro de Evangelización</h2>
                    <p class="desc">Sistema integrado para la gestión de cuadres, intenciones y administración general.</p>
                    <p class="report-title">Reporte Historial de Cuadres</p>
                    <p style="font-size: 11px; margin-top: 5px; color: #4B5563;">
                        Filtros: 
                        Desde <b>{{ $request->start_date ?? 'Inicio' }}</b> 
                        Hasta <b>{{ $request->end_date ?? 'Hoy' }}</b>
                        @if($request->module_id && $request->module_id !== 'null')
                            | Módulo ID: <b>{{ $request->module_id }}</b>
                        @endif
                    </p>
                </td>
                <td style="width: 100px;"></td> <!-- Espaciador para centrar el texto -->
            </tr>
        </table>
    </div>

    @php
        $totalFisico = 0;
        $totalDepositado = 0;
        $totalDiferencia = 0;
    @endphp

    <table class="data-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Módulo</th>
                <th>Fecha</th>
                <th>Estado</th>
                <th class="right">Físico</th>
                <th class="right">Depositado</th>
                <th class="right">Diferencia</th>
            </tr>
        </thead>
        <tbody>
            @forelse($reconciliations as $rec)
                @php
                    $finalDiff = $rec->is_deposited 
                        ? ($rec->deposit_difference ?? $rec->difference) 
                        : $rec->difference;
                        
                    $totalFisico += $rec->total_general;
                    $totalDepositado += ($rec->deposit_amount ?? 0);
                    $totalDiferencia += $finalDiff;
                @endphp
                <tr>
                    <td>{{ $rec->id }}</td>
                    <td>{{ $rec->module ? $rec->module->name : 'N/A' }}</td>
                    <td>{{ $rec->date }}</td>
                    <td>
                        @if($rec->is_deposited)
                            <span style="color: #10B981;">Depositado</span>
                        @else
                            <span style="color: #F59E0B;">Pendiente</span>
                        @endif
                    </td>
                    <td class="right">${{ number_format($rec->total_general, 2) }}</td>
                    <td class="right">${{ number_format($rec->deposit_amount ?? 0, 2) }}</td>
                    <td class="right">
                        @if($finalDiff == 0)
                            <span class="status-perfect">$0.00</span>
                        @elseif($finalDiff < 0)
                            <span class="status-faltante">-${{ number_format(abs($finalDiff), 2) }}</span>
                        @else
                            <span class="status-sobrante">+${{ number_format($finalDiff, 2) }}</span>
                        @endif
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="7" class="center" style="color:#9ca3af;">No hay cuadres en este rango</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    @if($reconciliations->count() > 0)
    <div class="clearfix">
        <div class="summary-box">
            <div class="summary-row">
                <span class="label">Total Físico (Acumulado):</span>
                <span class="val total">${{ number_format($totalFisico, 2) }}</span>
            </div>
            <div class="summary-row" style="margin-top: 5px;">
                <span class="label">Total Depositado (Acumulado):</span>
                <span class="val total" style="color: #10B981;">${{ number_format($totalDepositado, 2) }}</span>
            </div>
            <hr style="border: 0; border-top: 1px solid #E5E7EB; margin: 10px 0;">
            <div class="summary-row" style="margin-top: 10px;">
                <span class="label">Diferencia Total:</span>
                <span class="val 
                    @if($totalDiferencia == 0) status-perfect 
                    @elseif($totalDiferencia < 0) status-faltante 
                    @else status-sobrante 
                    @endif
                ">
                    @if($totalDiferencia < 0) - @elseif($totalDiferencia > 0) + @endif
                    ${{ number_format(abs($totalDiferencia), 2) }}
                </span>
            </div>
        </div>
    </div>
    @endif

    <div style="margin-top: 50px; text-align: center; color: #9ca3af; clear: both;">
        <p style="font-size: 12px; margin-top: 20px;">Generado por Sistema de Gestión de Iglesia el {{ now()->format('d/m/Y H:i:s') }}</p>
    </div>

</body>
</html>
