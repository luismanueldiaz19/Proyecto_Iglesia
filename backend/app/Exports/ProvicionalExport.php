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

        if ($this->type === 'ingresos' || $this->type === 'all' || empty($this->type)) {
            $sheets[] = new IngresosSheet($this->startDate, $this->endDate, $this->search);
        }

        if ($this->type === 'gastos' || $this->type === 'all' || empty($this->type)) {
            $sheets[] = new GastosSheet($this->startDate, $this->endDate, $this->search);
        }

        return $sheets;
    }
}
