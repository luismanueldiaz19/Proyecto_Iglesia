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
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #002B5B;
            padding-bottom: 10px;
        }
        .header h1 {
            color: #002B5B;
            margin: 0;
            font-size: 24px;
        }
        .header p {
            margin: 5px 0 0 0;
            color: #666;
            font-size: 14px;
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

    <div class="header">
        <h1>Historial de Registros de Auditoría</h1>
        <p>Reporte generado el: {{ \Carbon\Carbon::now()->format('d/m/Y H:i A') }}</p>
    </div>

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

</body>
</html>
