<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Cuadre de Caja #{{ $reconciliation->id }}</title>
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
        .header-icon {
            text-align: center;
            display: inline-block;
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
            font-size: 16px;
            font-weight: bold;
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
        .grid-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 22px;
        }
        .grid-table td {
            width: 25%;
            vertical-align: top;
            padding-bottom: 10px;
        }
        .label-text {
            margin: 0 0 4px;
            font-size: 11px;
            letter-spacing: 0.5px;
            color: #6b7280;
            text-transform: uppercase;
        }
        .value-text {
            margin: 0;
            font-size: 15px;
            font-weight: bold;
            color: #111827;
        }
        .status-perfect { color: #10B981; }
        .status-faltante { color: #EF4444; }
        .status-sobrante { color: #F59E0B; }
        
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
        h3 {
            color: #111827;
            font-size: 16px;
            margin-top: 30px;
            margin-bottom: 10px;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 5px;
        }
    </style>
</head>
<body>

<div class="report-card">
    @include('pdf.components.header', [
        'title' => 'Cuadre de Caja',
        'period' => 'No. ' . str_pad($reconciliation->id, 6, '0', STR_PAD_LEFT)
    ])

    <div class="body-section">
        <table class="title-table">
            <tr>
                <td>
                    <h1 class="title-text">Reporte Oficial de Cuadre</h1>
                </td>
                <td class="date-text">
                    Generado: {{ now()->format('d M Y, h:i a') }}
                </td>
            </tr>
        </table>

        <!-- Info Grid (Bottom Head) -->
        <table class="grid-table">
            <tr>
                <td>
                    <p class="label-text">Fecha de Cuadre</p>
                    <p class="value-text">{{ $reconciliation->date }}</p>
                </td>
                <td>
                    <p class="label-text">Módulo</p>
                    <p class="value-text">{{ $reconciliation->module ? $reconciliation->module->name : 'N/A' }}</p>
                </td>
                <td colspan="2">
                    <p class="label-text">Estado del Cuadre</p>
                    <p class="value-text">
                        @if($reconciliation->difference == 0)
                            <span class="status-perfect">CUADRE PERFECTO</span>
                        @elseif($reconciliation->difference < 0)
                            <span class="status-faltante">FALTANTE DE CAJA (RD$ {{ number_format(abs($reconciliation->difference), 2) }})</span>
                        @else
                            <span class="status-sobrante">SOBRANTE DE CAJA (RD$ {{ number_format($reconciliation->difference, 2) }})</span>
                        @endif
                    </p>
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
                <span class="label">Cuadre:</span>
                <span class="val">${{ number_format($reconciliation->total_general, 2) }}</span>
            </div>
            <div class="summary-row">
                <span class="label">Gastos Registrados:</span>
                <span class="val">-${{ number_format($reconciliation->total_expenses, 2) }}</span>
            </div>
            <div class="summary-row">
                <span class="label">Neto:</span>
                <span class="val">${{ number_format($reconciliation->total_general - $reconciliation->total_expenses, 2) }}</span>
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
            <span class="label">Diferencia Final (Depósito vs Neto):</span>
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

    @if($reconciliation->notes)
    <div style="margin-top: 20px; padding: 10px; background-color: #F3F4F6; border-radius: 8px;">
        <h4 style="margin: 0 0 5px 0; color: #374151; font-size: 14px;">Notas / Observaciones</h4>
        <p style="margin: 0; color: #4B5563; font-size: 13px;">{{ $reconciliation->notes }}</p>
    </div>
    @endif

        @include('pdf.components.footer')
    </div>

</body>
</html>
