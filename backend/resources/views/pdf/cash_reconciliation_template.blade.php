<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Plantilla de Cuadre de Caja Físico</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #333;
            font-size: 14px;
            margin: 0;
            padding: 20px;
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
        .signature-section {
            margin-top: 40px;
            width: 100%;
        }
        .signature-table {
            width: 100%;
            border-collapse: collapse;
        }
        .signature-table td {
            width: 50%;
            padding: 30px 10px 10px 10px;
            text-align: center;
            vertical-align: bottom;
        }
        .signature-line {
            border-bottom: 1px solid #333;
            width: 80%;
            margin: 0 auto 5px auto;
        }
        .signature-label {
            font-size: 12px;
            color: #6B7280;
        }
    </style>
</head>
<body>

    @include('pdf.components.header', [
        'title' => 'Plantilla de Cuadre de Caja Físico'
    ])


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
    </table>

    <h3>Desglose Físico (Billetes y Monedas)</h3>
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

    <div class="signature-section">
        <table class="signature-table">
            <tr>
                <td>
                    <div class="signature-line"></div>
                    <div class="signature-label">Firma Participante</div>
                </td>
                <td>
                    <div class="signature-line"></div>
                    <div class="signature-label">Firma Participante</div>
                </td>
            </tr>
            <tr>
                <td>
                    <div class="signature-line"></div>
                    <div class="signature-label">Firma Participante</div>
                </td>
                <td>
                    <div class="signature-line"></div>
                    <div class="signature-label">Firma Participante</div>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <div class="signature-line" style="width: 40%;"></div>
                    <div class="signature-label">Firma Participante</div>
                </td>
            </tr>
        </table>
    </div>

    <div style="margin-top: 30px; text-align: center; color: #9ca3af;">
        <p style="font-size: 11px;">Generado por Sistema de Gestión de Iglesia el {{ now()->format('d/m/Y H:i:s') }}</p>
    </div>

</body>
</html>
