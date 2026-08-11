<table style="width: 100%; border-bottom: 3px solid #1e40af; padding-bottom: 20px; margin-bottom: 30px; border-collapse: collapse;">
    <tr>
        <td style="width: 110px; text-align: left; vertical-align: middle; border: none; padding: 0;">
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
                <img src="{{ $logoData }}" alt="Logo Parroquia" style="max-width: 95px; max-height: 95px; object-fit: contain;">
            @endif
        </td>
        <td style="text-align: center; vertical-align: middle; border: none; padding: 0;">
            <h1 style="color: #1e3a8a; margin: 0; font-size: 20px; font-weight: 900; letter-spacing: 1px; text-transform: uppercase;">Fundación Centro de Evangelización<br>Padre Fantino</h1>
            <p style="margin: 6px 0 0; color: #6b7280; font-size: 11px; line-height: 1.4;">
                RNC: 3-30-37238-2 | Tel: (809) 697-8028<br>
                Av. Presidente Antonio Guzmán Fernández, Jamo Las Vegas,<br>
                tramo Controba-San Francisco de Macorís.
            </p>
            @if(isset($title))
                <div style="margin-top: 15px;">
                    <span style="background-color: #eff6ff; color: #1e40af; padding: 8px 16px; border-radius: 4px; border: 1px solid #bfdbfe; font-size: 16px; font-weight: bold; text-transform: uppercase; display: inline-block;">
                        {{ $title }}
                    </span>
                </div>
            @endif
            @if(isset($period))
                <p style="font-size: 11px; margin-top: 8px; color: #4B5563;">
                    {!! $period !!}
                </p>
            @endif
        </td>
        <td style="width: 100px; border: none; padding: 0;"></td> <!-- Espaciador para centrar el texto -->
    </tr>
</table>
