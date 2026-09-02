{{--
    resources/views/pdf/components/header.blade.php

    Componente de header reutilizable para reportes en PDF (dompdf).
    Diseñado usando TABLAS en la raíz para garantizar que ocupe el 100% 
    del ancho de su contenedor sin márgenes extraños.
--}}

<style>
    /* Reset y tipografía */
    .header-table-root {
        width: 100%;
        border-collapse: collapse;
        font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
        color: #1f2937;
        /* Linea inferior sólida para que toque los bordes del parent si es que lo desea,
           pero la aplicaremos a los TDs para más seguridad en dompdf */
    }

    .header-table-root td {
        vertical-align: middle;
        padding-top: 24px;
        padding-bottom: 16px;
        border-bottom: 2px solid #f3f4f6; /* Linea que divide el header del contenido */
    }

    .logo-cell {
        width: 85px;
        padding-left: 32px; /* Margen izquierdo exacto del body */
        padding-right: 16px;
        text-align: left;
    }

    .logo-cell img {
        width: 72px;
        height: 72px;
        border-radius: 50%;
        object-fit: cover;
    }

    .org-cell {
        text-align: left;
    }

    .org-name {
        font-size: 18px;
        font-weight: bold;
        color: #1e3a8a;
        text-transform: uppercase;
        line-height: 1.2;
        letter-spacing: 0.5px;
    }

    .org-meta {
        font-size: 10px;
        color: #4b5563;
        margin-top: 6px;
        font-weight: 500;
    }

    .org-address {
        font-size: 9px;
        color: #6b7280;
        margin-top: 3px;
        line-height: 1.4;
    }

    .badge-cell {
        text-align: right;
        padding-right: 32px; /* Margen derecho exacto del body */
        width: 250px;
    }

    .badge-text {
        font-size: 13px;
        font-weight: bold;
        letter-spacing: 1px;
        color: #0b2e6b;
        border-right: 3px solid #d4a017;
        padding-right: 12px;
        text-transform: uppercase;
        line-height: 1.4;
        display: inline-block;
        text-align: right;
    }

    /* Fila de metadatos inferior (opcional) */
    .meta-table-root {
        width: 100%;
        border-collapse: collapse;
        font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
    }
    
    .meta-table-root td {
        padding: 8px 32px 16px 32px; /* Mismos paddings L/R, padding top pequeño */
        font-size: 10px;
        vertical-align: middle;
        border-bottom: 1px solid #e5e7eb; /* linea separadora extra fina */
    }

    .meta-left {
        text-align: left;
        color: #4b5563;
    }

    .meta-right {
        text-align: right;
        color: #6b7280;
    }
</style>

{{-- Tabla Principal (Logo, Título, Badge) --}}
<table class="header-table-root">
    <tr>
        <td class="logo-cell">
            @php
                $logoPath = public_path('logo_app.jpeg');
                if (!file_exists($logoPath)) {
                    $logoPath = public_path('images/logo.png');
                }
                
                $logoData = '';
                if(file_exists($logoPath)) {
                    $type = pathinfo($logoPath, PATHINFO_EXTENSION);
                    $data = file_get_contents($logoPath);
                    $logoData = 'data:image/' . $type . ';base64,' . base64_encode($data);
                }
            @endphp
            @if($logoData)
                <img src="{{ $logoData }}" alt="Logo">
            @else
                <div style="width: 72px; height: 72px; background-color: #e5e7eb; border-radius: 50%; text-align: center; line-height: 72px; color: #9ca3af; font-size: 20px; font-weight: bold;">?</div>
            @endif
        </td>
        
        <td class="org-cell">
            <div class="org-name">
                Fundación Centro de Evangelización<br>
                Padre Fantino
            </div>
            <div class="org-meta">
                RNC: 43-30-37238-2 &nbsp;|&nbsp; Tel: (809) 697-8028
            </div>
            <div class="org-address">
                Av. Presidente Antonio Guzmán Fernández, Jamo Las Vegas,<br>
                tramo Controba - San Francisco de Macorís.
            </div>
        </td>
        
        <td class="badge-cell">
            <div class="badge-text">
                {{ $reportTitle ?? ($title ?? 'REPORTE PROVISIONAL') }}
            </div>
        </td>
    </tr>
</table>

{{-- Tabla Secundaria (Filtros y Fecha) --}}
<table class="meta-table-root">
    <tr>
        <td class="meta-left">
            @if(isset($filtros))
                <strong>Filtros:</strong> {!! $filtros !!}
            @elseif(isset($period))
                <strong>Periodo:</strong> {!! $period !!}
            @endif
        </td>
        <td class="meta-right">
            Generado: {{ now()->format('d M Y, h:i A') }}
        </td>
    </tr>
</table>