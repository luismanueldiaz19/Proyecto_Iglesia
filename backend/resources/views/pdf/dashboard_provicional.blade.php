<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Provisionales</title>
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
        
        table.data-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; font-size: 10px; }
        table.data-table th, table.data-table td { border: 1px solid #E5E7EB; padding: 4px 8px; text-align: left; }
        table.data-table th { 
            background-color: #F9FAFB; 
            color: #374151; 
            font-weight: bold; 
        }
        table.data-table td.amount { text-align: right; font-weight: bold; }
        table.data-table tr:nth-child(even) { background-color: #f8fafc; }
        
        .summary-boxes-table { width: 100%; margin-top: 15px; margin-bottom: 15px; border-collapse: collapse; border: none !important; }
        .summary-boxes-table td { border: none !important; vertical-align: top; }
        .summary-box { 
            background-color: #f8fafc; 
            border-top: 2px solid #94a3b8 !important; 
            padding: 8px 5px !important; 
            text-align: center;
            width: 32%;
            border-radius: 4px;
        }
        .summary-box.income { border-top-color: #22c55e !important; background-color: #f0fdf4; }
        .summary-box.expense { border-top-color: #ef4444 !important; background-color: #fef2f2; }
        .summary-box.balance { border-top-color: #3b82f6 !important; background-color: #eff6ff; }
        
        .summary-box h3 { margin: 0 0 4px 0; font-size: 10px; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; }
        .summary-box .amount { font-size: 14px; font-weight: bold; }
        
        .text-green { color: #15803d; }
        .text-red { color: #b91c1c; }
        .text-blue { color: #1d4ed8; }

        .footer-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 40px;
            border-top: 1px solid #e5e7eb;
            padding-top: 20px;
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
    @include('pdf.components.header', [
        'title' => 'Dashboard Provisionales',
        'period' => ($startDate && $endDate) ? "$startDate a $endDate" : 'Histórico Completo'
    ])

    <div class="body-section">
        <table class="title-table">
            <tr>
                <td>
                    <h1 class="title-text">Reporte Financiero</h1>
                </td>
                <td class="date-text">
                    Generado: {{ now()->format('d M Y, h:i a') }}
                </td>
            </tr>
        </table>

        <table class="summary-boxes-table">
            <tr>
                <td class="summary-box income">
                    <h3>Total Ingresos</h3>
                    <div class="amount text-green">${{ number_format($totalIngresos, 2) }}</div>
                </td>
                <td style="width: 2%;"></td>
                <td class="summary-box expense">
                    <h3>Total Gastos</h3>
                    <div class="amount text-red">${{ number_format($totalGastos, 2) }}</div>
                </td>
                <td style="width: 2%;"></td>
                <td class="summary-box balance">
                    <h3>Balance (Saldo)</h3>
                    <div class="amount text-blue">${{ number_format($balance, 2) }}</div>
                </td>
            </tr>
        </table>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Mes</th>
                    <th class="amount">Ingresos</th>
                    <th class="amount">Gastos</th>
                    <th class="amount">Diferencia</th>
                </tr>
            </thead>
            <tbody>
                @foreach($datosPorMes as $fila)
                    <tr>
                        <td>{{ $fila['mes'] }}</td>
                        <td class="amount text-green">${{ number_format($fila['ingresos'], 2) }}</td>
                        <td class="amount text-red">${{ number_format($fila['gastos'], 2) }}</td>
                        <td class="amount {{ $fila['diferencia'] >= 0 ? 'text-blue' : 'text-red' }}">
                            ${{ number_format($fila['diferencia'], 2) }}
                        </td>
                    </tr>
                @endforeach
                @if(empty($datosPorMes))
                    <tr>
                        <td colspan="4" style="text-align: center; padding: 20px;">No hay registros en este período.</td>
                    </tr>
                @endif
            </tbody>
        </table>
        <div>
            <h2 class="title-text" style="font-size: 16px; margin-top: 30px; margin-bottom: 10px;">Detalles de Ingresos</h2>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Fecha</th>
                        <th>Concepto</th>
                        <th>Origen</th>
                        <th class="amount">Monto</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($detallesIngresos as $ingreso)
                        <tr>
                            <td>{{ \Carbon\Carbon::parse($ingreso->fecha_ingreso)->format('d/m/Y') }}</td>
                            <td>{{ $ingreso->concepto }}</td>
                            <td>{{ ucfirst($ingreso->origen) }}</td>
                            <td class="amount text-green">${{ number_format($ingreso->monto, 2) }}</td>
                        </tr>
                    @endforeach
                    @if($detallesIngresos->isEmpty())
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 20px;">No hay ingresos registrados en este período.</td>
                        </tr>
                    @endif
                </tbody>
            </table>
        </div>

        <div>
            <h2 class="title-text" style="font-size: 16px; margin-top: 30px; margin-bottom: 10px;">Detalles de Gastos</h2>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Fecha</th>
                        <th>Concepto</th>
                        <th>Num. Cheque</th>
                        <th>Origen</th>
                        <th class="amount">Monto</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($detallesGastos as $gasto)
                        <tr>
                            <td>{{ \Carbon\Carbon::parse($gasto->fecha_gasto)->format('d/m/Y') }}</td>
                            <td>{{ $gasto->concepto }}</td>
                            <td>{{ $gasto->num_check }}</td>
                            <td>{{ ucfirst($gasto->origen) }}</td>
                            <td class="amount text-red">${{ number_format($gasto->monto, 2) }}</td>
                        </tr>
                    @endforeach
                    @if($detallesGastos->isEmpty())
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 20px;">No hay gastos registrados en este período.</td>
                        </tr>
                    @endif
                </tbody>
            </table>
        </div>
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
                        Tel (809) 697-8028 · RNC 43-30-37238-2
                    </p>
                </td>
            </tr>
        </table>
    </div> <!-- end body section -->
</div> <!-- end report card -->

</body>
</html>
