<?php

namespace App\Exports;

use App\Models\IngresoProvicional;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;

class IngresosSheet implements FromCollection, WithHeadings, WithTitle
{
    public function collection()
    {
        return IngresoProvicional::select('fecha_ingreso', 'concepto', 'monto')->get();
    }

    public function headings(): array
    {
        return ['Fecha Ingreso', 'Concepto', 'Monto'];
    }

    public function title(): string
    {
        return 'Ingresos';
    }
}
