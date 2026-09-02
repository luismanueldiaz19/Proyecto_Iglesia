<?php

namespace App\Exports;

use App\Models\GastoProvicional;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;

class GastosSheet implements FromCollection, WithHeadings, WithTitle
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
        $query = GastoProvicional::select('fecha_gasto', 'concepto', 'num_check', 'monto');

        if ($this->startDate) {
            $query->whereDate('fecha_gasto', '>=', $this->startDate);
        }

        if ($this->endDate) {
            $query->whereDate('fecha_gasto', '<=', $this->endDate);
        }

        if ($this->search) {
            $searchTerm = '%' . $this->search . '%';
            $query->where('concepto', 'ilike', $searchTerm);
        }

        return $query->get();
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
