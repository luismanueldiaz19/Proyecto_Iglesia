<?php

namespace App\Exports;

use App\Models\GastoProvicional;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;

class GastosSheet implements FromCollection, WithHeadings, WithTitle
{
    public function collection()
    {
        return GastoProvicional::select('fecha_gasto', 'concepto', 'num_check', 'monto')->get();
    }

    public function headings(): array
    {
        return ['Fecha Gasto', 'Concepto', 'Num Check', 'Monto'];
    }

    public function title(): string
    {
        return 'Gastos';
    }
}
