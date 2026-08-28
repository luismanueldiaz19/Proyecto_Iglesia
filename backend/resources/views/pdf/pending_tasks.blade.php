<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Tareas Pendientes</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            font-size: 12px;
            color: #333;
            margin: 0;
            padding: 0;
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
            margin-top: 0;
        }
        .header-table td {
            padding: 28px 32px;
            vertical-align: middle;
            border: none;
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
            margin-top: 0;
        }
        .title-table td {
            padding-bottom: 16px;
            vertical-align: bottom;
            border: none;
        }
        .title-text {
            margin: 0;
            font-size: 20px;
            font-weight: bold;
            color: #111827;
            text-transform: uppercase;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #002B5B;
            color: white;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .status {
            font-weight: bold;
        }
        .status-pendiente {
            color: #d97706;
        }
        .status-terminado {
            color: #166534;
        }
        .footer {
            margin-top: 50px;
            text-align: center;
            font-size: 10px;
            color: #999;
            border-top: 1px solid #ddd;
            padding-top: 10px;
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
                <p class="header-title-large" style="margin: 0; font-size: 16px; text-transform: uppercase; line-height: 1.3;">Fundación Centro de<br>Evangelización Padre Fantino</p>
            </td>
            <td>
                <p class="header-receipt-text">Reporte de Tareas</p>
                <p class="header-receipt-number">Generado el <b>{{ \Carbon\Carbon::now()->format('Y-m-d') }}</b></p>
            </td>
        </tr>
    </table>

    <div class="body-section">
        <table class="title-table">
            <tr>
                <td>
                    <h1 class="title-text">Historial de Registros de Auditoría</h1>
                </td>
            </tr>
        </table>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Título</th>
                <th>Fecha Plan.</th>
                <th>Fecha Real.</th>
                <th>Estado</th>
                <th>Registrado Por</th>
            </tr>
        </thead>
        <tbody>
            @forelse($tasks as $task)
                <tr>
                    <td style="border-bottom: none;">{{ $task->id }}</td>
                    <td style="border-bottom: none;">{{ $task->title }}</td>
                    <td style="border-bottom: none;">{{ \Carbon\Carbon::parse($task->plan_date)->format('d/m/Y') }}</td>
                    <td style="border-bottom: none;">{{ $task->completed_date ? \Carbon\Carbon::parse($task->completed_date)->format('d/m/Y H:i') : '-' }}</td>
                    <td style="border-bottom: none;" class="status {{ strtolower($task->status) == 'terminado' ? 'status-terminado' : 'status-pendiente' }}">
                        {{ $task->status }}
                    </td>
                    <td style="border-bottom: none;">{{ $task->user->name ?? $task->user->username ?? 'Sistema' }}</td>
                </tr>
                <tr>
                    <td colspan="6" style="padding-top: 5px; padding-bottom: 15px; border-top: none; font-size: 11px; color: #555;">
                        <strong>Detalles:</strong> {{ $task->details }}
                        @if(!empty($task->comments))
                            <br><strong>Comentarios:</strong> {{ $task->comments }}
                        @endif
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="6" style="text-align: center; padding: 20px;">No hay registros para los filtros seleccionados.</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="footer">
        Este documento es un reporte generado por el sistema automatizado de la Iglesia.
    </div>

    </div> <!-- end body section -->
</div> <!-- end report card -->

</body>
</html>
