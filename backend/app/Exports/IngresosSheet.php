<?php

namespace App\Exports;

use App\Models\IngresoProvicional;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;

class IngresosSheet implements FromCollection, WithHeadings, WithTitle
{
    protected $startDate;
    protected $endDate;
    protected $search;

    public function __construct($startDate = null, $endDate = null, $search = null)
    {
        $this->startDate = $startDate;
        $this->endDate = $endDate;
        $this->search = $search;
    }

    public function collection()
    {
        $query = IngresoProvicional::select('fecha_ingreso', 'concepto', 'monto');

        if ($this->startDate) {
            $query->whereDate('fecha_ingreso', '>=', $this->startDate);
        }

        if ($this->endDate) {
            $query->whereDate('fecha_ingreso', '<=', $this->endDate);
        }

        if ($this->search) {
            $searchTerm = '%' . $this->search . '%';
            $query->where('concepto', 'ilike', $searchTerm);
        }

        return $query->get();
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
