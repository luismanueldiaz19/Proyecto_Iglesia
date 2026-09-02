<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\WithMultipleSheets;

class ProvicionalExport implements WithMultipleSheets
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

    public function sheets(): array
    {
        return [
            new IngresosSheet($this->startDate, $this->endDate, $this->search),
            new GastosSheet($this->startDate, $this->endDate, $this->search)
        ];
    }
}
