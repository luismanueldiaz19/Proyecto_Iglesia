<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte Provisional</title>
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
            padding: 12px 24px 20px 24px;
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
            margin-bottom: 12px;
            font-size: 9px; /* Tamaño equilibrado */
            line-height: 1.3;
        }
        table.data-table th, table.data-table td {
            border: 1px solid #E5E7EB;
            padding: 2px 4px; /* Un poco más de aire para que respire */
            text-align: left;
            vertical-align: middle;
        }
        table.data-table th {
            background-color: #F9FAFB;
            color: #374151;
            font-weight: bold;
        }
        table.data-table .amount {
            text-align: right;
            font-weight: bold;
        }
        table.data-table tr:nth-child(even) { background-color: #f8fafc; }

        table.data-table .total-row td {
            font-size: 11px;
            font-weight: bold;
            color: #0B2E6B;
            background-color: #eff6ff;
            border-top: 1px solid #1e40af;
            border-bottom: 1px solid #1e40af;
            padding: 6px 10px;
        }

        h2 {
            color: #111827;
            font-size: 13px;
            margin-top: 8px;
            margin-bottom: 6px;
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 2px;
        }

    </style>
</head>
<body>

<div class="report-card">
    @include('pdf.components.header', [
        'title' => 'Reporte de Gastos Provisionales',
        'period' => (isset($startDate) && isset($endDate)) ? "$startDate al $endDate" : 'Histórico Completo'
    ])

    <div class="body-section">
        <h2>Gastos</h2>
        <table class="data-table">
            <thead>
                <tr>
                     <th>Fecha</th>
                    <th>Descripción</th>
                    <th>Cheque</th>
                    <th>Registrado por</th>
                    <th class="amount">Monto</th>
                </tr>
            </thead>
            <tbody>
                @forelse($gastos as $gasto)
                <tr>
                    <td>{{ $gasto->fecha_gasto }}</td>
                    <td>{{ $gasto->concepto }}</td>
                    <td>{{ (!empty($gasto->num_check) && strtolower(trim($gasto->num_check)) !== 'n/a') ? $gasto->num_check : '' }}</td>
                    <td>{{ $gasto->user->name ?? 'N/A' }}</td>
                    <td class="amount">${{ number_format($gasto->monto, 2) }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="5" style="text-align: center; color: #6b7280;">No hay gastos registrados</td>
                </tr>
                @endforelse
            </tbody>
            <tfoot>
                @php
                    $uniqueChecks = $gastos->filter(function($g) {
                        return !empty($g->num_check) && strtolower(trim($g->num_check)) !== 'n/a';
                    })->pluck('num_check')->unique()->count();
                @endphp
                <tr class="total-row">
                    <td colspan="4" style="text-align: right; text-transform: uppercase; letter-spacing: 1px;">Total Gastos:</td>
                    <td class="amount">${{ number_format($gastos->sum('monto'), 2) }}</td>
                </tr>
                <tr class="total-row" style="background-color: #ffffff; border-top: none;">
                    <td colspan="4" style="text-align: right; text-transform: uppercase; letter-spacing: 1px; color: #4b5563; font-size: 9px; border-top: none;">Total Cheques Emitidos:</td>
                    <td class="amount" style="color: #4b5563; font-size: 9px; border-top: none;">{{ $uniqueChecks }}</td>
                </tr>
            </tfoot>
        </table>

        @include('pdf.components.footer')
    </div> <!-- end body section -->
</div> <!-- end report card -->

</body>
</html>
