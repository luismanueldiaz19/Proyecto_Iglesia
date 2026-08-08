<!DOCTYPE html>
<html>
<head>
    <title>Historial de Donaciones</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; }
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
        
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
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
                    <p class="report-title">Historial de Donaciones</p>
                </td>
                <td style="width: 100px;"></td> <!-- Espaciador para centrar el texto -->
            </tr>
        </table>
    </div>
    
    <table>
        <thead>
            <tr>
                <th>No. Recibo</th>
                <th>Fecha</th>
                <th>Donante</th>
                <th>Cédula/RNC</th>
                <th>Concepto</th>
                <th>Método</th>
                <th>Monto</th>
            </tr>
        </thead>
        <tbody>
            @php $total = 0; @endphp
            @foreach($donations as $donation)
            <tr>
                <td>{{ str_pad($donation->id, 5, '0', STR_PAD_LEFT) }}</td>
                <td>{{ $donation->created_at->format('Y-m-d H:i') }}</td>
                <td>{{ $donation->donor_name }}</td>
                <td>{{ $donation->donor_cedula ?? $donation->donor_rnc ?? 'N/A' }}</td>
                <td>{{ $donation->concept }}</td>
                <td>{{ $donation->payment_method }}</td>
                <td style="text-align: right;">${{ number_format($donation->amount, 2) }}</td>
            </tr>
            @php $total += $donation->amount; @endphp
            @endforeach
        </tbody>
        <tfoot>
            <tr>
                <th colspan="6" style="text-align: right;">Total General:</th>
                <th style="text-align: right;">${{ number_format($total, 2) }}</th>
            </tr>
        </tfoot>
    </table>
</body>
</html>
