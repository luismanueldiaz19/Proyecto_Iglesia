<?php

namespace App\Imports;

use App\Models\IngresoProvicional;
use App\Models\BankTransaction;
use App\Models\BankAccount;
use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use PhpOffice\PhpSpreadsheet\Shared\Date;
use Illuminate\Support\Facades\DB;

class IngresoProvicionalImport implements ToCollection, WithHeadingRow
{
    protected $userId;
    protected $bankAccountId;

    public function __construct($userId, $bankAccountId)
    {
        $this->userId = $userId;
        $this->bankAccountId = $bankAccountId;
    }

    public function collection(Collection $rows) {
        DB::transaction(function () use ($rows) {
            $bankAccount = BankAccount::find($this->bankAccountId);
            if (!$bankAccount) {
                throw new \Exception('Cuenta bancaria no encontrada.');
            }

            foreach ($rows as $row) {
                $fecha = $row['fecha_ingreso'] ?? $row['fecha'] ?? null;
                $concepto = $row['concepto'] ?? $row['conceptos'] ?? $row['descripcion'] ?? null;
                $monto = $row['monto'] ?? $row['valor'] ?? $row['cantidad'] ?? null;

                // Limpiar el monto de caracteres como '$' y ','
                if ($monto !== null) {
                    $monto = str_replace(['$', ',', ' '], '', $monto);
                }

                // Skip completely empty rows
                if (!$fecha && !$concepto && !$monto) {
                    continue;
                }

                if (!$fecha || !$concepto || !$monto) {
                    throw new \Exception('Una fila no tiene los datos requeridos o las columnas no se llaman fecha_ingreso (o fecha), concepto, monto.');
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

                $ingreso = IngresoProvicional::create([
                    'fecha_ingreso' => $fecha,
                    'concepto' => $concepto,
                    'monto' => $monto,
                    'usuario_registro' => $this->userId,
                ]);

                BankTransaction::create([
                    'bank_account_id' => $this->bankAccountId,
                    'date' => $fecha,
                    'type' => 'deposit',
                    'amount' => $monto,
                    'reference' => 'ING-' . $ingreso->id,
                    'description' => $concepto,
                    'status' => 'transit',
                ]);

                $bankAccount->current_balance += $monto;
            }
            $bankAccount->save();
        });
    }
}
