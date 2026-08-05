<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Provisionales</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; color: #333; margin: 0; padding: 20px; }
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
        
        .summary-boxes { width: 100%; margin-bottom: 20px; text-align: center; }
        .summary-box { display: inline-block; width: 30%; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 15px; box-sizing: border-box; }
        .summary-box h3 { margin: 0 0 10px 0; font-size: 13px; color: #475569; }
        .summary-box .amount { font-size: 18px; font-weight: bold; }
        .text-green { color: #16a34a; }
        .text-red { color: #dc2626; }
        .text-blue { color: #2563eb; }

        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; font-size: 11px; }
        th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
        th { background-color: #f1f5f9; color: #1e293b; font-weight: bold; text-transform: uppercase; }
        td.amount { text-align: right; }
        tr:nth-child(even) { background-color: #f8fafc; }
        .footer { text-align: center; font-size: 10px; color: #94a3b8; border-top: 1px solid #ddd; padding-top: 10px; margin-top: 30px; }
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
                    <p class="report-title">Dashboard - Provisionales</p>
                    <p style="font-size: 11px; margin-top: 5px; color: #4B5563;">
                        @if($startDate && $endDate)
                            Período: <b>{{ $startDate }} al {{ $endDate }}</b>
                        @else
                            Período: <b>Histórico Completo</b>
                        @endif
                    </p>
                </td>
                <td style="width: 100px;"></td> <!-- Espaciador para centrar el texto -->
            </tr>
        </table>
    </div>

    <div class="summary-boxes">
        <div class="summary-box">
            <h3>Total Ingresos</h3>
            <div class="amount text-green">${{ number_format($totalIngresos, 2) }}</div>
        </div>
        <div class="summary-box">
            <h3>Total Gastos</h3>
            <div class="amount text-red">${{ number_format($totalGastos, 2) }}</div>
        </div>
        <div class="summary-box">
            <h3>Balance (Saldo)</h3>
            <div class="amount text-blue">${{ number_format($balance, 2) }}</div>
        </div>
    </div>

    <table>
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

    <div class="footer">
        Generado por Sistema de Gestión Provisionales &copy; {{ date('Y') }}
    </div>

</body>
</html>
