<?php

namespace App\Imports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use PhpOffice\PhpSpreadsheet\Shared\Date;

class PreviewIngresoProvicionalImport implements ToCollection, WithHeadingRow
{
    public $parsedData = [];
    public $totalAmount = 0;

    public function collection(Collection $rows)
    {
        foreach ($rows as $row) {
            $fecha = $row['fecha_ingreso'] ?? $row['fecha'] ?? null;
            $concepto = $row['concepto'] ?? $row['conceptos'] ?? $row['descripcion'] ?? null;
            $monto = $row['monto'] ?? $row['valor'] ?? $row['cantidad'] ?? null;

            // Limpiar el monto de caracteres como '$' y ','
            if ($monto !== null) {
                $monto = str_replace(['$', ',', ' '], '', $monto);
            }

            // Skip completely empty rows
            if (!$fecha && (!$concepto || trim($concepto) === '') && (!$monto || trim($monto) === '')) {
                continue;
            }

            if (!$fecha || !$concepto || !$monto) {
                throw new \Exception('Una fila no tiene los datos requeridos o las columnas no se llaman fecha, concepto, monto.');
            }

            // Convert Excel date to PHP date if necessary
            if (is_numeric($fecha)) {
                $fecha = Date::excelToDateTimeObject($fecha)->format('Y-m-d');
            } else {
                $parsedDate = null;
                $formats = ['m/d/Y', 'n/j/Y', 'd/m/Y', 'j/n/Y', 'Y-m-d', 'd-m-Y', 'j-n-Y', 'n-j-Y', 'Y/m/d', 'd.m.Y'];
                
                foreach ($formats as $format) {
                    try {
                        $parsedDate = \Carbon\Carbon::createFromFormat($format, $fecha);
                        break;
                    } catch (\Exception $e) {
                        continue;
                    }
                }

                if (!$parsedDate) {
                    $timestamp = strtotime($fecha);
                    if ($timestamp !== false) {
                        $parsedDate = \Carbon\Carbon::createFromTimestamp($timestamp);
                    }
                }

                if (!$parsedDate) {
                    throw new \Exception("La fecha '$fecha' tiene un formato no válido. Use MM/DD/YYYY o DD-MM-YYYY.");
                }
                
                $fecha = $parsedDate->format('Y-m-d');
            }

            $montoValue = floatval($monto);
            $this->totalAmount += $montoValue;

            $this->parsedData[] = [
                'fecha_ingreso' => $fecha,
                'concepto' => $concepto,
                'monto' => $montoValue,
            ];
        }
    }
}
