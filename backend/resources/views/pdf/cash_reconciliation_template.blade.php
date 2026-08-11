<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Plantilla de Cuadre de Caja Físico</title>
    <style>
        @page {
            margin: 15px; /* Reduce los márgenes generales de la hoja PDF */
        }
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #333;
            font-size: 14px;
            margin: 0;
            padding: 2px; /* Reducido para que la tarjeta ocupe más ancho */
        }
        .receipt-card {
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
            width: 52px;
            height: 52px;
            background-color: #D4A017;
            border-radius: 50%;
            text-align: center;
            line-height: 52px;
            color: #0B2E6B;
            font-size: 26px;
            font-weight: bold;
            display: inline-block;
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
        }
        .date-text {
            font-size: 12px;
            color: #6b7280;
            text-align: right;
        }

        .info-grid {
            width: 100%;
            margin-bottom: 20px;
        }
        .info-grid td {
            padding: 5px;
            vertical-align: top;
            border-bottom: 1px dashed #ccc;
        }
        .info-label {
            font-weight: bold;
            color: #6B7280;
        }
        
        table.data-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        table.data-table th, table.data-table td {
            border: 1px solid #E5E7EB;
            padding: 10px;
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
        table.data-table .center {
            text-align: center;
        }
        .currency-header {
            background-color: #eef2ff !important;
            color: #0B2E6B !important;
            font-weight: bold;
            font-size: 15px;
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
            margin-bottom: 10px;
        }
        .summary-row .label {
            display: table-cell;
            text-align: left;
            font-weight: bold;
            color: #374151;
            font-size: 16px;
        }
        .summary-row .val {
            display: table-cell;
            text-align: right;
            font-weight: bold;
        }
        .footer-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 30px;
            border-top: 1px solid #e5e7eb;
            padding-top: 20px;
        }
        .footer-table td {
            vertical-align: bottom;
            padding-top: 20px;
        }
        .signature-line {
            width: 150px;
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

    <div class="receipt-card">
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
                        <div class="header-icon">+</div>
                    @endif
                </td>
                <td>
                    <p class="header-title-large" style="margin: 0; font-size: 16px; text-transform: uppercase; line-height: 1.3;">Fundación Centro de Evangelización<br>Padre Fantino</p>
                </td>
                <td>
                    <p class="header-receipt-text">Plantilla</p>
                    <p class="header-receipt-number">Cuadre Físico</p>
                </td>
            </tr>
        </table>

        <!-- Body -->
        <div class="body-section">
            <table class="title-table">
                <tr>
                    <td>
                        <h1 class="title-text">Plantilla de Cuadre de Caja Físico</h1>
                    </td>
                    <td class="date-text">
                        Impreso: {{ now()->format('d M Y, h:i a') }}
                    </td>
                </tr>
            </table>

            <table class="info-grid">
                <tr>
                    <td class="info-label" width="15%">Fecha:</td>
                    <td width="35%">________________________</td>
                    <td class="info-label" width="15%">Módulo:</td>
                    <td width="35%">________________________</td>
                </tr>
                <tr>
                    <td class="info-label">Turno/Hora:</td>
                    <td>________________________</td>
                    <td class="info-label">Cajero(a):</td>
                    <td>________________________</td>
                </tr>
                <tr>
                    <td class="info-label">Tasa USD:</td>
                    <td>________________________</td>
                    <td class="info-label">Tasa EUR:</td>
                    <td>________________________</td>
                </tr>
            </table>

            <h3 style="color: #374151; font-size: 16px;">Desglose Físico (Billetes y Monedas)</h3>
            <table class="data-table">
                <thead>
                    <tr>
                        <th width="17%">Denominación</th>
                        <th class="center" width="10%">Cant.</th>
                        <th class="right" width="23%">Total Físico</th>
                        
                        <th width="17%">Denominación</th>
                        <th class="center" width="10%">Cant.</th>
                        <th class="right" width="23%">Total Físico</th>
                    </tr>
                </thead>
                <tbody>
                    @php
                        $grouped = $denominations->groupBy('currency');
                    @endphp
                    
                    @foreach(['DOP', 'USD', 'EUR'] as $currency)
                        @if($grouped->has($currency))
                            <tr>
                                <td colspan="6" class="currency-header">Moneda: {{ $currency }}</td>
                            </tr>
                            @php
                                $chunks = $grouped[$currency]->chunk(2);
                            @endphp
                            @foreach($chunks as $chunk)
                                @php $items = $chunk->values(); @endphp
                                <tr>
                                    @if(isset($items[0]))
                                        <td>{{ number_format($items[0]->value, 0) }} {{ $items[0]->type == 'bill' ? 'Billetes' : 'Monedas' }}</td>
                                        <td class="center"></td>
                                        <td class="right"></td>
                                    @else
                                        <td></td><td></td><td></td>
                                    @endif

                                    @if(isset($items[1]))
                                        <td>{{ number_format($items[1]->value, 0) }} {{ $items[1]->type == 'bill' ? 'Billetes' : 'Monedas' }}</td>
                                        <td class="center"></td>
                                        <td class="right"></td>
                                    @else
                                        <td></td><td></td><td></td>
                                    @endif
                                </tr>
                            @endforeach
                        @endif
                    @endforeach
                </tbody>
            </table>

            <div class="summary-box">
                <div class="summary-row">
                    <span class="label">Total Efectivo Físico Contado:</span>
                    <span class="val">_____________________________________</span>
                </div>
                <div class="summary-row" style="margin-top: 15px;">
                    <span class="label">Total Sobrante / Faltante (Si aplica):</span>
                    <span class="val">_____________________________________</span>
                </div>
                <div class="summary-row" style="margin-top: 15px;">
                    <span class="label">Observaciones:</span>
                    <span class="val" style="width: 70%; display: inline-block; border-bottom: 1px solid #ccc;">&nbsp;</span>
                </div>
            </div>

            <table style="width: 100%; text-align: center; margin-top: 40px; border-collapse: collapse;">
                <tr>
                    <td style="padding-bottom: 40px; width: 33%;">
                        <div class="signature-line" style="margin: 0 auto; width: 80%;"></div>
                        <p class="signature-text" style="text-align: center;">Firma Autorizada</p>
                    </td>
                    <td style="padding-bottom: 40px; width: 33%;">
                        <div class="signature-line" style="margin: 0 auto; width: 80%;"></div>
                        <p class="signature-text" style="text-align: center;">Firma Participante</p>
                    </td>
                    <td style="padding-bottom: 40px; width: 33%;">
                        <div class="signature-line" style="margin: 0 auto; width: 80%;"></div>
                        <p class="signature-text" style="text-align: center;">Firma Participante</p>
                    </td>
                </tr>
                <tr>
                    <td style="width: 33%;">
                        <div class="signature-line" style="margin: 0 auto; width: 80%;"></div>
                        <p class="signature-text" style="text-align: center;">Firma Participante</p>
                    </td>
                    <td style="width: 33%;">
                        <div class="signature-line" style="margin: 0 auto; width: 80%;"></div>
                        <p class="signature-text" style="text-align: center;">Firma Participante</p>
                    </td>
                    <td style="width: 33%;">
                        <!-- Espacio vacío -->
                    </td>
                </tr>
            </table>

            <div style="text-align: center; margin-top: 25px; border-top: 1px solid #e5e7eb; padding-top: 15px;">
                <p class="address-text" style="text-align: center; color: #6b7280; font-size: 11px; margin: 0;">
                    Av. Presidente Antonio Guzmán Fernández | Jamo Las Vegas, tramo Controba - San Francisco de Macorís<br/>
                    Tel (809) 697-8028 · RNC 3-30-37238-2
                </p>
            </div>

        </div> <!-- end body-section -->
    </div> <!-- end receipt-card -->

    <div style="margin-top: 15px; text-align: center; color: #9ca3af;">
        <p style="font-size: 11px;">Generado por Sistema de Gestión de Iglesia el {{ now()->format('d/m/Y H:i:s') }}</p>
    </div>

</body>
</html>
