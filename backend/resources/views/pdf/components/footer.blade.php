{{--
    resources/views/pdf/components/footer.blade.php

    Componente de footer reutilizable para reportes en PDF (dompdf).
--}}

<style>
    .footer-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 40px;
        border-top: 1px solid #e5e7eb;
        padding-top: 20px;
        clear: both;
    }
    .footer-table td {
        vertical-align: bottom;
        padding-top: 20px;
    }
    .signature-line {
        width: 180px;
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

<table class="footer-table">
    <tr>
        <td style="width: 40%;">
            <div class="signature-line"></div>
            <p class="signature-text">Administración</p>
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
