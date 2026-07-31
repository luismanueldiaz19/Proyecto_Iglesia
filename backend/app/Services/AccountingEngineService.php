<?php

namespace App\Services;

use App\Models\AccountingEngineConfig;
use App\Models\JournalEntry;
use App\Models\JournalEntryLine;
use Illuminate\Support\Facades\DB;
use Exception;

class AccountingEngineService
{
    /**
     * Registra una transacción contable automáticamente según la configuración.
     *
     * @param string $operationCode Código de la operación (ej. 'VENTA_LIBRERIA')
     * @param float $amount Monto total o base de la transacción
     * @param string $description Descripción del asiento
     * @param float|null $taxAmount Opcional: Monto de impuesto si se calcula externamente. Si es null, se calcula usando el % de la config.
     * @param int|null $referenceId ID del modelo de referencia (ej. Sale->id)
     * @param string|null $referenceType Clase del modelo de referencia (ej. App\Models\Sale)
     * @return JournalEntry
     * @throws Exception
     */
    public function recordTransaction(
        string $operationCode,
        float $amount,
        string $description,
        ?float $taxAmount = null,
        ?int $referenceId = null,
        ?string $referenceType = null
    ) {
        $config = AccountingEngineConfig::where('operation_code', $operationCode)->first();

        if (!$config) {
            throw new Exception("Configuración contable no encontrada para la operación: {$operationCode}");
        }

        return DB::transaction(function () use ($config, $amount, $description, $taxAmount, $referenceId, $referenceType) {
            $entry = JournalEntry::create([
                'date' => now(),
                'description' => $description,
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
            ]);

            // Lógica de Impuestos (ITBIS)
            $calculatedTaxAmount = 0;
            if ($config->tax_account_id) {
                if ($taxAmount !== null) {
                    $calculatedTaxAmount = $taxAmount;
                } else if ($config->tax_percentage > 0) {
                    $calculatedTaxAmount = $amount * ($config->tax_percentage / 100);
                }
            }

            // Dependiendo de la operación, el total debitado puede ser monto + impuesto
            // Asumimos que $amount es la base imponible y se le suma el ITBIS para la cuenta de destino (Débito)
            // Ejemplo de Venta: Débito Caja (Monto + ITBIS), Crédito Ingreso (Monto), Crédito ITBIS (ITBIS).
            
            $totalAmount = $amount + $calculatedTaxAmount;

            // Línea de Débito (Ej. Caja o Banco)
            JournalEntryLine::create([
                'journal_entry_id' => $entry->id,
                'account_id' => $config->debit_account_id,
                'debit' => $totalAmount,
                'credit' => 0,
            ]);

            // Línea de Crédito Principal (Ej. Ingreso o Gasto)
            JournalEntryLine::create([
                'journal_entry_id' => $entry->id,
                'account_id' => $config->credit_account_id,
                'debit' => 0,
                'credit' => $amount,
            ]);

            // Línea de Impuesto si aplica
            if ($calculatedTaxAmount > 0 && $config->tax_account_id) {
                // En una venta normal, el impuesto se acredita (ITBIS por Pagar)
                JournalEntryLine::create([
                    'journal_entry_id' => $entry->id,
                    'account_id' => $config->tax_account_id,
                    'debit' => 0,
                    'credit' => $calculatedTaxAmount,
                ]);
            }

            // Validar Partida Doble
            $totalDebit = JournalEntryLine::where('journal_entry_id', $entry->id)->sum('debit');
            $totalCredit = JournalEntryLine::where('journal_entry_id', $entry->id)->sum('credit');

            // Float comparison con tolerancia
            if (abs($totalDebit - $totalCredit) > 0.01) {
                throw new Exception("Error de Partida Doble: Los débitos ({$totalDebit}) no coinciden con los créditos ({$totalCredit}).");
            }

            return $entry;
        });
    }

    /**
     * Registra un asiento manual o generado a partir de múltiples líneas (ej. Cierre de Caja).
     *
     * @param string $description
     * @param array $lines [['account_id' => int, 'debit' => float, 'credit' => float]]
     * @param int|null $referenceId
     * @param string|null $referenceType
     * @return JournalEntry
     * @throws Exception
     */
    public function recordManualEntry(
        string $description,
        array $lines,
        ?int $referenceId = null,
        ?string $referenceType = null
    ) {
        return DB::transaction(function () use ($description, $lines, $referenceId, $referenceType) {
            $totalDebit = 0;
            $totalCredit = 0;

            foreach ($lines as $line) {
                $totalDebit += $line['debit'] ?? 0;
                $totalCredit += $line['credit'] ?? 0;
            }

            if (abs($totalDebit - $totalCredit) > 0.01) {
                throw new Exception("Error de Partida Doble: Los débitos ({$totalDebit}) no coinciden con los créditos ({$totalCredit}).");
            }

            $entry = JournalEntry::create([
                'date' => now(),
                'description' => $description,
                'reference_id' => $referenceId,
                'reference_type' => $referenceType,
            ]);

            foreach ($lines as $line) {
                JournalEntryLine::create([
                    'journal_entry_id' => $entry->id,
                    'account_id' => $line['account_id'],
                    'debit' => $line['debit'] ?? 0,
                    'credit' => $line['credit'] ?? 0,
                ]);
            }

            return $entry;
        });
    }
}
