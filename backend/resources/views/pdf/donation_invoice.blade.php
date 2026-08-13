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
            padding: 10px;
            
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
            width: 50%;
            vertical-align: top;
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
        .amount-table {
            width: 100%;
            background-color: #f9fafb;
            border-collapse: collapse;
            margin-bottom: 24px;
            border-radius: 8px;
        }
        .amount-table td {
            padding: 16px 20px;
            vertical-align: middle;
        }
        .amount-label {
            font-size: 13px;
            color: #4b5563;
        }
        .amount-value {
            font-size: 26px;
            font-weight: bold;
            color: #0B2E6B;
            text-align: right;
        }
        .details-table {
            width: 100%;
            font-size: 13px;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .details-table td {
            padding: 10px 0;
        }
        .details-label {
            color: #4b5563;
            width: 40%;
        }
        .details-value {
            text-align: right;
            color: #111827;
            font-weight: bold;
        }
        .border-top {
            border-top: 1px solid #e5e7eb;
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
                    <p class="header-receipt-text">Recibo</p>
                    <p class="header-receipt-number">No. {{ str_pad($donation->id, 5, '0', STR_PAD_LEFT) }}</p>
                </td>
            </tr>
        </table>

        <!-- Body -->
        <div class="body-section">
            <table class="title-table">
                <tr>
                    <td>
                        <h1 class="title-text">Comprobante de donación</h1>
                    </td>
                    <td class="date-text">
                        {{ $donation->created_at->format('d M Y, h:i a') }}
                    </td>
                </tr>
            </table>

            <table class="grid-table">
                <tr>
                    <td>
                        <p class="label-text">Recibido de</p>
                        <p class="value-text">{{ $donation->donor_name }}</p>
                    </td>
                    <td>
                        <p class="label-text">Concepto</p>
                        <p class="value-text">{{ $donation->concept }}</p>
                    </td>
                </tr>
            </table>

            @if($donation->donor_cedula || $donation->donor_rnc)
            <table class="grid-table" style="margin-top: -10px;">
                <tr>
                    <td>
                        @if($donation->donor_cedula)
                            <p class="label-text">Cédula</p>
                            <p class="value-text">{{ $donation->donor_cedula }}</p>
                        @endif
                    </td>
                    <td>
                        @if($donation->donor_rnc)
                            <p class="label-text">RNC</p>
                            <p class="value-text">{{ $donation->donor_rnc }}</p>
                        @endif
                    </td>
                </tr>
            </table>
            @endif

            <table class="amount-table">
                <tr>
                    <td class="amount-label">Monto recibido</td>
                    <td class="amount-value">RD$ {{ number_format($donation->amount, 2) }}</td>
                </tr>
            </table>

            <table class="details-table">
                <tr>
                    <td class="details-label">Método de pago</td>
                    <td class="details-value">{{ $donation->payment_method }}</td>
                </tr>
                <tr class="border-top">
                    <td class="details-label">Recibido por</td>
                    <td class="details-value">{{ $donation->user ? $donation->user->name : 'Administración' }}</td>
                </tr>
                <tr class="border-top">
                    <td class="details-label">Tipo de Recibo</td>
                    <td class="details-value">
                        @if($donation->with_receipt)
                            Válido para Crédito Fiscal
                        @else
                            Consumidor Final
                        @endif
                    </td>
                </tr>
            </table>

            <table class="footer-table">
                <tr>
                    <td style="width: 40%;">
                        <div class="signature-line"></div>
                        <p class="signature-text">Firma autorizada</p>
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
        </div>
    </div>

</body>
</html>
