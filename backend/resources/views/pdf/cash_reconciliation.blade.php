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
            text-align: center;
            border-bottom: 2px solid #0B2E6B;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .header h1 {
            color: #0B2E6B;
            margin: 0;
            font-size: 24px;
        }
        .header p {
            margin: 5px 0 0;
            color: #6B7280;
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
        <h1>Centro de Evangelización</h1>
        <p>Reporte Oficial de Cuadre de Caja</p>
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
        <div class="summary-row">
            <span class="label">Saldo Esperado:</span>
            <span class="val">${{ number_format($reconciliation->transactions->where('type', 'income')->sum('amount') - $reconciliation->transactions->where('type', 'expense')->sum('amount'), 2) }}</span>
        </div>
        <div class="summary-row" style="margin-top: 15px;">
            <span class="label">Efectivo Físico Contado:</span>
            <span class="val total">${{ number_format($reconciliation->total_general, 2) }}</span>
        </div>
        <div class="summary-row" style="margin-top: 15px;">
            <span class="label">Diferencia:</span>
            <span class="val 
                @if($reconciliation->difference == 0) status-perfect 
                @elseif($reconciliation->difference < 0) status-faltante 
                @else status-sobrante 
                @endif
            ">
                ${{ number_format($reconciliation->difference, 2) }}
            </span>
        </div>
    </div>

    <div style="margin-top: 50px; text-align: center; color: #9ca3af;">
        <p>_____________________________________</p>
        <p>Firma Responsable / Cajero</p>
        <p style="font-size: 12px; margin-top: 20px;">Generado por Sistema de Gestión de Iglesia el {{ now()->format('d/m/Y H:i:s') }}</p>
    </div>

</body>
</html>
