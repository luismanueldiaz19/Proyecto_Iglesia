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
    <!-- Header -->
    <table class="header-table">
        <tr>
            <td style="width: 70px;">
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
                    <img src="{{ $logoData }}" style="width: 52px; height: 52px; border-radius: 50%; border: 2px solid #D4A017; object-fit: cover; background-color: white; vertical-align: middle; display: inline-block;" alt="Logo">
                @else
                    <div style="width: 52px; height: 52px; background-color: #D4A017; border-radius: 50%; text-align: center; line-height: 52px; color: #0B2E6B; font-size: 26px; font-weight: bold; display: inline-block;">+</div>
                @endif
            </td>
            <td>
                <p class="header-title-large" style="margin: 0; font-size: 16px; text-transform: uppercase; line-height: 1.3;">Fundación Centro de Evangelización<br>Padre Fantino</p>
            </td>
            <td>
                <p class="header-receipt-text">Historial de Cuadres</p>
                <p class="header-receipt-number">Desde <b>{{ $request->start_date ?? 'Inicio' }}</b> <br> Hasta <b>{{ $request->end_date ?? 'Hoy' }}</b></p>
            </td>
        </tr>
    </table>

    <div class="body-section">
        <table class="title-table">
            <tr>
                <td>
                    <h1 class="title-text">Reporte Historial de Cuadres</h1>
                </td>
                <td class="date-text">
                    Generado: {{ now()->format('d M Y, h:i a') }}
                    @if($request->module_id && $request->module_id !== 'null')
                        <br>Filtro Módulo ID: {{ $request->module_id }}
                    @endif
                </td>
            </tr>
        </table>

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
                    @if($totalDiferencia < 0)
                        -${{ number_format(abs($totalDiferencia), 2) }}
                    @else
                        ${{ number_format($totalDiferencia, 2) }}
                    @endif
                </span>
            </div>
        </div>
    </div>
    @endif

        <table class="footer-table">
            <tr>
                <td style="width: 40%;">
                    <div class="signature-line"></div>
                    <p class="signature-text">Administración</p>
                </td>
                <td style="width: 60%;">
                    <p class="address-text">
                        Av. Presidente Antonio Guzmán Fernández<br/>
                        Jamo Las Vegas, tramo Controba - San Francisco de Macorís<br/>
                        Tel (809) 697-8028 · RNC 3-30-37238-2
                    </p>
                </td>
            </tr>
        </table>
    </div> <!-- end body section -->
</div> <!-- end report card -->

</body>
</html>
