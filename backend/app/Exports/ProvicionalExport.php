<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\WithMultipleSheets;

class ProvicionalExport implements WithMultipleSheets
{
    public function sheets(): array
    {
        return [
            new IngresosSheet(),
            new GastosSheet()
        ];
    }
}
