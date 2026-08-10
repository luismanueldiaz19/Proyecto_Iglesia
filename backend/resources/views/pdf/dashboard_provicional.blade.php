<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Provisionales</title>
    <style>
        body { font-family: 'Helvetica', 'Arial', sans-serif; font-size: 12px; color: #374151; margin: 0; padding: 20px; background-color: #ffffff; }
        .header {
            width: 100%;
            border-bottom: 3px solid #1e40af;
            padding-bottom: 20px;
            margin-bottom: 30px;
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
            width: 110px;
            text-align: left;
        }
        .header-logo img {
            max-width: 95px;
            max-height: 95px;
            object-fit: contain;
        }
        .header-text {
            text-align: center;
        }
        .header-text h1 {
            color: #1e3a8a;
            margin: 0;
            font-size: 28px;
            font-weight: 900;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }
        .header-text h2 {
            color: #4b5563;
            margin: 6px 0 0;
            font-size: 16px;
            font-weight: bold;
        }
        .header-text p.desc {
            margin: 6px 0 0;
            color: #6b7280;
            font-size: 12px;
        }
        .header-text p.report-title {
            margin: 20px 0 0;
            color: #1e40af;
            font-size: 20px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .badge {
            background-color: #eff6ff;
            color: #1e40af;
            display: inline-block;
            padding: 8px 16px;
            border-radius: 4px;
            border: 1px solid #bfdbfe;
        }
        .summary-boxes-table { width: 100%; margin-top: 35px; margin-bottom: 35px; border-collapse: collapse; border: none !important; }
        .summary-boxes-table td { border: none !important; vertical-align: top; }
        .summary-box { 
            background-color: #f8fafc; 
            border-top: 4px solid #94a3b8 !important; 
            padding: 20px 10px !important; 
            text-align: center;
            width: 32%;
        }
        .summary-box.income { border-top-color: #22c55e !important; background-color: #f0fdf4; }
        .summary-box.expense { border-top-color: #ef4444 !important; background-color: #fef2f2; }
        .summary-box.balance { border-top-color: #3b82f6 !important; background-color: #eff6ff; }
        
        .summary-box h3 { margin: 0 0 12px 0; font-size: 14px; color: #475569; text-transform: uppercase; letter-spacing: 0.5px; }
        .summary-box .amount { font-size: 22px; font-weight: bold; }
        
        .text-green { color: #15803d; }
        .text-red { color: #b91c1c; }
        .text-blue { color: #1d4ed8; }

        table { width: 100%; border-collapse: collapse; margin-bottom: 30px; font-size: 12px; }
        th, td { border: 1px solid #e2e8f0; padding: 12px 15px; text-align: left; }
        th { 
            background-color: #1e40af; 
            color: #ffffff; 
            font-weight: bold; 
            text-transform: uppercase;
            font-size: 11px;
            letter-spacing: 0.5px;
        }
        td.amount { text-align: right; font-weight: bold; }
        tr:nth-child(even) { background-color: #f8fafc; }
        
        .footer { text-align: center; font-size: 11px; color: #94a3b8; border-top: 1px solid #e2e8f0; padding-top: 15px; margin-top: 40px; }
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
                    <p class="report-title"><span class="badge">Dashboard - Provisionales</span></p>
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

    <div class="footer">
        Generado por Sistema de Gestión Provisionales &copy; {{ date('Y') }}
    </div>

</body>
</html>
