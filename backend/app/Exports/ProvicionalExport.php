<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\WithMultipleSheets;

class ProvicionalExport implements WithMultipleSheets
{
    protected $startDate;
    protected $endDate;
    protected $search;
    protected $type;

    public function __construct($startDate = null, $endDate = null, $search = null, $type = null)
    {
        $this->startDate = $startDate;
        $this->endDate = $endDate;
        $this->search = $search;
        $this->type = $type;
    }

    public function sheets(): array
    {
        $sheets = [];
        
        $type = $this->type;
        if (!in_array($type, ['ingresos', 'gastos'])) {
            $type = 'all';
        }

        if ($type === 'ingresos' || $type === 'all') {
            $sheets[] = new IngresosSheet($this->startDate, $this->endDate, $this->search);
        }

        if ($type === 'gastos' || $type === 'all') {
            $sheets[] = new GastosSheet($this->startDate, $this->endDate, $this->search);
        }

        return $sheets;
    }
}
