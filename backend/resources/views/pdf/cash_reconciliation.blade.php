<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Cuadre de Caja #{{ $reconciliation->id }}</title>
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
        .info-grid {
            width: 100%;
            margin-bottom: 20px;
        }
        .info-grid td {
            padding: 5px;
            vertical-align: top;
        }
        .info-label {
            font-weight: bold;
            color: #6B7280;
        }
        .status-perfect { color: #10B981; font-weight: bold; }
        .status-faltante { color: #EF4444; font-weight: bold; }
        .status-sobrante { color: #F59E0B; font-weight: bold; }
        
        table.data-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        table.data-table th, table.data-table td {
            border: 1px solid #E5E7EB;
            padding: 8px;
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
        .summary-box {
            background-color: #F9FAFB;
            border: 1px solid #E5E7EB;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
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
            font-size: 18px;
            color: #0B2E6B;
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
                    <p class="report-title">Reporte Oficial de Cuadre de Caja</p>
                </td>
                <td style="width: 100px;"></td> <!-- Espaciador para centrar el texto -->
            </tr>
        </table>
    </div>

    <table class="info-grid">
        <tr>
            <td class="info-label" width="15%">No. Cuadre:</td>
            <td width="35%">{{ str_pad($reconciliation->id, 6, '0', STR_PAD_LEFT) }}</td>
            <td class="info-label" width="15%">Fecha:</td>
            <td width="35%">{{ $reconciliation->date }}</td>
        </tr>
        <tr>
            <td class="info-label">Módulo:</td>
            <td>{{ $reconciliation->module ? $reconciliation->module->name : 'N/A' }}</td>
            <td class="info-label">Estado:</td>
            <td>
                @if($reconciliation->difference == 0)
                    <span class="status-perfect">CUADRE PERFECTO</span>
                @elseif($reconciliation->difference < 0)
                    <span class="status-faltante">FALTANTE DE CAJA</span>
                @else
                    <span class="status-sobrante">SOBRANTE DE CAJA</span>
                @endif
            </td>
        </tr>
    </table>

    <h3>Transacciones del Turno</h3>
    <table class="data-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Concepto</th>
                <th>Tipo</th>
                <th class="right">Monto</th>
            </tr>
        </thead>
        <tbody>
            @forelse($reconciliation->transactions as $tx)
                <tr>
                    <td>{{ $tx->id }}</td>
                    <td>{{ $tx->description }}</td>
                    <td>{{ $tx->type == 'income' ? 'Ingreso' : 'Gasto' }}</td>
                    <td class="right">${{ number_format($tx->amount, 2) }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="4" style="text-align:center; color:#9ca3af;">No hay transacciones registradas</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <h3>Desglose Físico (Billetes y Monedas)</h3>
    <table class="data-table">
        <thead>
            <tr>
                <th>Moneda / Denominación</th>
                <th class="right">Cantidad</th>
                <th class="right">Total (Calculado)</th>
            </tr>
        </thead>
        <tbody>
            @forelse($reconciliation->denominations as $den)
                <tr>
                    <td>{{ $den->denomination->currency }} - {{ number_format($den->denomination->value, 0) }}</td>
                    <td class="right">{{ $den->quantity }}</td>
                    <td class="right">${{ number_format($den->total, 2) }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="3" style="text-align:center; color:#9ca3af;">No hay desglose físico registrado</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="summary-box">
        <div class="summary-row">
            <span class="label">Ingresos Calculados:</span>
            <span class="val">${{ number_format($reconciliation->transactions->where('type', 'income')->sum('amount'), 2) }}</span>
        </div>
        <div class="summary-row">
            <span class="label">Gastos Calculados:</span>
            <span class="val">-${{ number_format($reconciliation->transactions->where('type', 'expense')->sum('amount'), 2) }}</span>
        </div>
        <hr style="border: 0; border-top: 1px solid #E5E7EB; margin: 10px 0;">
        <div class="summary-row" style="margin-top: 15px;">
            <span class="label">Efectivo Físico Contado (Ingreso del Turno):</span>
            <span class="val total">${{ number_format($reconciliation->total_general, 2) }}</span>
        </div>
        @if($reconciliation->is_deposited)
        <hr style="border: 0; border-top: 1px dashed #E5E7EB; margin: 15px 0;">
        <div class="summary-row" style="margin-top: 10px;">
            <span class="label">Monto Depositado en Banco:</span>
            <span class="val total" style="color: #10B981;">${{ number_format($reconciliation->deposit_amount, 2) }}</span>
        </div>
        <div class="summary-row" style="margin-top: 15px;">
            <span class="label">Diferencia Final (Depósito vs Físico):</span>
            <span class="val 
                @if($reconciliation->deposit_difference == 0) status-perfect 
                @elseif($reconciliation->deposit_difference < 0) status-faltante 
                @else status-sobrante 
                @endif
            ">
                ${{ number_format($reconciliation->deposit_difference, 2) }}
            </span>
        </div>
        @endif
    </div>

    <div style="margin-top: 50px; text-align: center; color: #9ca3af;">
        <p>_____________________________________</p>
        <p>Firma Responsable / Cajero</p>
        <p style="font-size: 12px; margin-top: 20px;">Generado por Sistema de Gestión de Iglesia el {{ now()->format('d/m/Y H:i:s') }}</p>
    </div>

</body>
</html>
