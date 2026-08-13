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
            margin-bottom: 30px;
            font-size: 12px;
        }
        table.data-table th, table.data-table td {
            border: 1px solid #E5E7EB;
            padding: 8px 12px;
            text-align: left;
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

        h2 {
            color: #111827;
            font-size: 16px;
            margin-top: 30px;
            margin-bottom: 10px;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 5px;
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
                <p class="header-title-small">Centro de evangelización</p>
                <p class="header-title-large">Padre Fantino</p>
            </td>
            <td>
                <p class="header-receipt-text">Reporte</p>
                <p class="header-receipt-number">Provisional</p>
            </td>
        </tr>
    </table>

    <div class="body-section">
        <table class="title-table">
            <tr>
                <td>
                    <h1 class="title-text">Reporte Provisional</h1>
                </td>
                <td class="date-text">
                    Generado: {{ now()->format('d M Y, h:i a') }}
                </td>
            </tr>
        </table>
    
        <h2>Ingresos</h2>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Fecha</th>
                    <th>Concepto</th>
                    <th>Usuario Registro</th>
                    <th class="amount">Monto</th>
                </tr>
            </thead>
            <tbody>
                @forelse($ingresos as $ingreso)
                <tr>
                    <td>{{ $ingreso->fecha_ingreso }}</td>
                    <td>{{ $ingreso->concepto }}</td>
                    <td>{{ $ingreso->user->name ?? 'N/A' }}</td>
                    <td class="amount">${{ number_format($ingreso->monto, 2) }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="4" style="text-align: center; color: #6b7280;">No hay ingresos registrados</td>
                </tr>
                @endforelse
            </tbody>
        </table>

        <h2>Gastos</h2>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Fecha</th>
                    <th>Concepto</th>
                    <th>Num Check</th>
                    <th>Usuario Registro</th>
                    <th class="amount">Monto</th>
                </tr>
            </thead>
            <tbody>
                @forelse($gastos as $gasto)
                <tr>
                    <td>{{ $gasto->fecha_gasto }}</td>
                    <td>{{ $gasto->concepto }}</td>
                    <td>{{ $gasto->num_check ?? 'N/A' }}</td>
                    <td>{{ $gasto->user->name ?? 'N/A' }}</td>
                    <td class="amount">${{ number_format($gasto->monto, 2) }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="5" style="text-align: center; color: #6b7280;">No hay gastos registrados</td>
                </tr>
                @endforelse
            </tbody>
        </table>

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
