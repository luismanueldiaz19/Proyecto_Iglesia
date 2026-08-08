<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Recibo de Donación #{{ str_pad($donation->id, 5, '0', STR_PAD_LEFT) }}</title>
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
        .info-section {
            width: 100%;
            margin-bottom: 30px;
        }
        .info-table {
            width: 100%;
            border-collapse: collapse;
        }
        .info-table td {
            padding: 8px 0;
            vertical-align: top;
        }
        .info-label {
            font-weight: bold;
            color: #555;
            width: 30%;
        }
        .info-value {
            color: #000;
            border-bottom: 1px dotted #ccc;
        }
        .amount-section {
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin-bottom: 40px;
        }
        .amount-title {
            font-size: 16px;
            color: #555;
            margin-bottom: 10px;
        }
        .amount-value {
            font-size: 32px;
            font-weight: bold;
            color: #0B2E6B;
        }
        .signature-section {
            width: 100%;
            margin-bottom: 30px;
            margin-top: 80px;
        }
        .signature-table {
            width: 100%;
            text-align: center;
        }
        .signature-line {
            width: 80%;
            margin: 0 auto;
            border-top: 1px solid #333;
            padding-top: 5px;
            font-weight: bold;
        }
        .footer {
            margin-top: 50px;
            text-align: center;
            font-size: 11px;
            color: #999;
            border-top: 1px solid #eee;
            padding-top: 10px;
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
                    @else
                        <!-- Fallback si no hay logo -->
                        <div style="width: 80px; height: 80px; background-color: #0B2E6B; color: white; text-align: center; line-height: 80px; font-weight: bold; font-size: 10px; border-radius: 8px;">
                            LOGO IGLESIA
                        </div>
                    @endif
                </td>
                <td class="header-text">
                    <h1>PARROQUIA</h1>
                    <h2>Centro de Evangelización</h2>
                    <p class="desc">Sistema integrado para la gestión de cuadres, intenciones y administración general.</p>
                    <p class="report-title">RECIBO DE DONACIÓN</p>
                    <p style="font-size: 12px; color: #666; margin-top: 5px;">
                        No. {{ str_pad($donation->id, 5, '0', STR_PAD_LEFT) }} | Fecha: {{ $donation->created_at->format('d/m/Y h:i A') }}
                    </p>
                </td>
                <td style="width: 100px;"></td> <!-- Espaciador -->
            </tr>
        </table>
    </div>

    <div class="info-section">
        <table class="info-table">
            <tr>
                <td class="info-label">Recibido de:</td>
                <td class="info-value">{{ $donation->donor_name }}</td>
            </tr>
            <tr>
                <td class="info-label">Teléfono:</td>
                <td class="info-value">{{ $donation->donor_phone ?? 'N/A' }}</td>
            </tr>
            <tr>
                <td class="info-label">Cédula:</td>
                <td class="info-value">{{ $donation->donor_cedula ?? 'N/A' }}</td>
            </tr>
            <tr>
                <td class="info-label">RNC:</td>
                <td class="info-value">{{ $donation->donor_rnc ?? 'N/A' }}</td>
            </tr>
            <tr>
                <td class="info-label">Concepto:</td>
                <td class="info-value">{{ $donation->concept }}</td>
            </tr>
            <tr>
                <td class="info-label">Método de Pago:</td>
                <td class="info-value">{{ $donation->payment_method }}</td>
            </tr>
            <tr>
                <td class="info-label">Tipo de Recibo:</td>
                <td class="info-value">
                    @if($donation->with_receipt)
                        <strong>Válido para Crédito Fiscal (Con Comprobante)</strong>
                    @else
                        Consumidor Final (Sin Comprobante)
                    @endif
                </td>
            </tr>
        </table>
    </div>

    <div class="amount-section">
        <div class="amount-title">Monto Recibido</div>
        <div class="amount-value">RD$ {{ number_format($donation->amount, 2) }}</div>
    </div>

    <div class="signature-section">
        <table class="signature-table">
            <tr>
                <td style="width: 50%;">
                    <div class="signature-line">Firma del Donante</div>
                </td>
                <td style="width: 50%;">
                    <div class="signature-line">
                        Firma Autorizada / Sello
                        <br>
                        <span style="font-size: 10px; font-weight: normal;">
                            {{ $donation->user ? $donation->user->name : 'Administración' }}
                        </span>
                    </div>
                </td>
            </tr>
        </table>
    </div>

    <div class="footer">
        Este documento es un comprobante de donación. ¡Que Dios multiplique su ofrenda!<br>
        Generado el {{ now()->format('d/m/Y h:i A') }}
    </div>

</body>
</html>
