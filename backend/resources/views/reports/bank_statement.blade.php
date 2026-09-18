<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Estado de Cuenta</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            color: #333;
            margin: 0;
            padding: 0;
            font-size: 12px;
        }
        .header {
            background-color: #0B2E6B;
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header-title {
            font-size: 24px;
            font-weight: bold;
            margin: 0;
        }
        .header-subtitle {
            font-size: 14px;
            margin-top: 5px;
            color: #E5E7EB;
        }
        .info-section {
            padding: 20px;
            display: table;
            width: 100%;
            border-bottom: 2px solid #E5E7EB;
        }
        .info-block {
            display: table-cell;
            width: 50%;
        }
        .info-label {
            font-size: 11px;
            color: #6B7280;
            text-transform: uppercase;
            font-weight: bold;
            margin-bottom: 4px;
        }
        .info-value {
            font-size: 16px;
            font-weight: bold;
            color: #1F2937;
        }
        .summary-box {
            background-color: #F0F2F5;
            padding: 15px;
            border-radius: 8px;
            margin-top: 10px;
            display: table;
            width: 100%;
        }
        .summary-item {
            display: table-cell;
            text-align: center;
            width: 33.33%;
            border-right: 1px solid #D1D5DB;
        }
        .summary-item:last-child {
            border-right: none;
        }
        .summary-item .info-value {
            color: #0B2E6B;
            font-size: 18px;
            margin-top: 5px;
        }
        .transactions-section {
            padding: 20px;
        }
        .section-title {
            font-size: 18px;
            color: #0B2E6B;
            margin-bottom: 15px;
            border-bottom: 1px solid #0B2E6B;
            padding-bottom: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th {
            background-color: #F0F2F5;
            color: #6B7280;
            font-size: 11px;
            text-transform: uppercase;
            padding: 10px 5px;
            text-align: left;
            border-bottom: 1px solid #D1D5DB;
        }
        td {
            padding: 10px 5px;
            border-bottom: 1px solid #E5E7EB;
            font-size: 12px;
        }
        .text-right {
            text-align: right;
        }
        .text-center {
            text-align: center;
        }
        .text-green {
            color: #10B981;
        }
        .text-red {
            color: #EF4444;
        }
        .footer {
            text-align: center;
            padding: 20px;
            font-size: 10px;
            color: #9CA3AF;
            margin-top: 30px;
            border-top: 1px solid #E5E7EB;
        }
    </style>
</head>
<body>

    <div class="header">
        <table width="100%">
            <tr>
                <td>
                    <h1 class="header-title">Estado de Cuenta</h1>
                    <div class="header-subtitle">Resumen de transacciones</div>
                </td>
                <td class="text-right" style="color: white;">
                    <h2 style="margin:0;">{{ env('APP_NAME', 'Comunidad') }}</h2>
                    <div>Generado el {{ \Carbon\Carbon::now()->format('d/m/Y h:i A') }}</div>
                </td>
            </tr>
        </table>
    </div>

    <div class="info-section">
        <div class="info-block">
            <div class="info-label">Cuenta</div>
            <div class="info-value">{{ $account->name }}</div>
            <div style="color: #6B7280; margin-top: 2px;">{{ $account->bank->name ?? 'Banco' }} • {{ $account->accountNumber ?? $account->account_number }}</div>
        </div>
        <div class="info-block text-right">
            <div class="info-label">Periodo</div>
            <div class="info-value">
                {{ $startDate->format('d/m/Y') }} - {{ $endDate->format('d/m/Y') }}
            </div>
        </div>
    </div>

    <div style="padding: 0 20px;">
        <div class="summary-box">
            <div class="summary-item">
                <div class="info-label">Balance Inicial</div>
                <div class="info-value">${{ number_format($initialBalance, 2) }}</div>
            </div>
            <div class="summary-item">
                <div class="info-label" style="color: #10B981;">+ Depósitos</div>
                <div class="info-value text-green">${{ number_format($totalDeposits, 2) }}</div>
            </div>
            <div class="summary-item">
                <div class="info-label" style="color: #EF4444;">- Retiros</div>
                <div class="info-value text-red">${{ number_format($totalWithdrawals, 2) }}</div>
            </div>
        </div>
        
        <div style="margin-top: 15px; text-align: right; font-size: 14px;">
            <span style="color: #6B7280; font-weight: bold; text-transform: uppercase;">Balance Final:</span>
            <span style="font-size: 20px; font-weight: bold; color: #0B2E6B; margin-left: 10px;">${{ number_format($finalBalance, 2) }}</span>
        </div>
    </div>

    <div class="transactions-section">
        <h3 class="section-title">Detalle de Transacciones</h3>
        
        @if($transactions->count() > 0)
        <table>
            <thead>
                <tr>
                    <th>Fecha</th>
                    <th>Referencia</th>
                    <th>Descripción</th>
                    <th class="text-right">Monto</th>
                    <th class="text-right">Balance Restante</th>
                </tr>
            </thead>
            <tbody>
                @php
                    $runningBalance = $initialBalance;
                @endphp
                @foreach($transactions as $tx)
                    @php
                        $runningBalance += $tx->amount;
                        $isDeposit = $tx->amount >= 0;
                    @endphp
                    <tr>
                        <td>{{ \Carbon\Carbon::parse($tx->date)->format('d/m/Y') }}</td>
                        <td>{{ $tx->reference ?? '-' }}</td>
                        <td>{{ $tx->description ?? $tx->type ?? 'Transacción' }}</td>
                        <td class="text-right {{ $isDeposit ? 'text-green' : 'text-red' }}">
                            {{ $isDeposit ? '+' : '' }}${{ number_format($tx->amount, 2) }}
                        </td>
                        <td class="text-right font-weight-bold">
                            ${{ number_format($runningBalance, 2) }}
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
        @else
        <p style="text-align: center; color: #6B7280; margin-top: 30px;">
            No hay transacciones en este periodo.
        </p>
        @endif
    </div>

    <div class="footer">
        Este es un documento generado electrónicamente. Los saldos aquí reflejados incluyen únicamente las transacciones registradas hasta la fecha de finalización del periodo seleccionado.
    </div>

</body>
</html>
