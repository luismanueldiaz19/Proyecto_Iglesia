<?php

namespace App\Modules\Prestamos\Services;

use App\Modules\Prestamos\Models\Loan;
use App\Modules\Prestamos\Models\LoanTransaction;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

class ApplyLoanPaymentService
{
    public function execute(Loan $loan, array $data): LoanTransaction
    {
        return DB::transaction(function () use ($loan, $data) {
            $capital = (float) ($data['capital_amount'] ?? 0);
            $interest = (float) ($data['interest_amount'] ?? 0);
            $lateFee = (float) ($data['late_fee_amount'] ?? 0);
            $insurance = (float) ($data['insurance_amount'] ?? 0);
            $legalFee = (float) ($data['legal_fee_amount'] ?? 0);
            $commission = (float) ($data['commission_amount'] ?? 0);
            $totalPaid = (float) $data['total_paid'];

            // 2. Control de balances
            $balanceBefore = (float) $loan->current_balance;
            $balanceAfter = round($balanceBefore - $totalPaid, 2);

            if ($balanceAfter < 0) {
                throw new InvalidArgumentException("El monto pagado ({$totalPaid}) excede el balance actual ({$balanceBefore}).");
            }

            // 3. Crear el movimiento
            $transaction = LoanTransaction::create([
                'loan_id' => $loan->id,
                'loan_installment_id' => $data['loan_installment_id'] ?? null,
                'bank_account_id' => $data['bank_account_id'] ?? null,
                'transaction_date' => $data['transaction_date'],
                'reference_type' => $data['reference_type'] ?? null,
                'reference_number' => $data['reference_number'] ?? null,
                'concept' => $data['concept'] ?? 'PAGO A PRESTAMO',
                'total_paid' => $totalPaid,
                'capital_amount' => $capital,
                'interest_amount' => $interest,
                'late_fee_amount' => $lateFee,
                'insurance_amount' => $insurance,
                'legal_fee_amount' => $legalFee,
                'commission_amount' => $commission,
                'balance_before' => $balanceBefore,
                'balance_after' => $balanceAfter,
                'voucher_path' => $data['voucher_path'] ?? null,
            ]);

            // 4. Actualizar el saldo del préstamo
            $newStatus = $balanceAfter <= 0 ? 'paid' : $loan->status;
            $loan->update([
                'current_balance' => $balanceAfter,
                'status' => $newStatus,
            ]);

            // 5. Integración Bancaria (Opcional)
            // Si el pago provino de una cuenta bancaria propia, registrar aquí el egreso en bank_transactions si se requiere en el futuro.

            return $transaction;
        });
    }
}
