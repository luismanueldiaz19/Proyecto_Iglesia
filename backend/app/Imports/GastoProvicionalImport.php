<?php

namespace App\Imports;

use App\Models\GastoProvicional;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use PhpOffice\PhpSpreadsheet\Shared\Date;

class GastoProvicionalImport implements ToModel, WithHeadingRow
{
    protected $userId;

    public function __construct($userId)
    {
        $this->userId = $userId;
    }

    /**
    * @param array $row
    *
    * @return \Illuminate\Database\Eloquent\Model|null
    */
    public function model(array $row)
    {
        $fecha = $row['fecha_gasto'] ?? $row['fecha'] ?? null;
        $concepto = $row['concepto'] ?? $row['conceptos'] ?? $row['descripcion'] ?? null;
        $monto = $row['monto'] ?? $row['valor'] ?? $row['cantidad'] ?? null;
        $numCheck = $row['num_check'] ?? $row['numero_cheque'] ?? $row['cheque'] ?? null;

        // Limpiar el monto de caracteres como '$' y ','
        if ($monto !== null) {
            $monto = str_replace(['$', ',', ' '], '', $monto);
        }

        // Skip completely empty rows
        if (!$fecha && !$concepto && !$monto) {
            return null;
        }

        // Throw an exception so the user knows what went wrong instead of silently skipping
        if (!$fecha || !$concepto || !$monto) {
            throw new \Exception('Una fila no tiene los datos requeridos o las columnas no se llaman fecha_gasto (o fecha), concepto, monto.');
        }

        // Convert Excel date to PHP date if necessary
        if (is_numeric($fecha)) {
            $fecha = \PhpOffice\PhpSpreadsheet\Shared\Date::excelToDateTimeObject($fecha)->format('Y-m-d');
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

        return new GastoProvicional([
            'fecha_gasto' => $fecha,
            'concepto' => $concepto,
            'num_check' => $numCheck,
            'monto' => $monto,
            'usuario_registro' => $this->userId,
        ]);
    }
}
