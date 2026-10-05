<?php

namespace App\Modules\Prestamos\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LoanTransaction extends Model
{
    protected $fillable = [
        'loan_id',
        'loan_installment_id',
        'bank_account_id',
        'bank_transaction_id',
        'transaction_date',
        'reference_type',
        'reference_number',
        'concept',
        'total_paid',
        'capital_amount',
        'interest_amount',
        'late_fee_amount',
        'insurance_amount',
        'legal_fee_amount',
        'commission_amount',
        'balance_before',
        'balance_after',
        'voucher_path',
    ];

    protected $casts = [
        'transaction_date' => 'date',
        'total_paid' => 'decimal:2',
        'capital_amount' => 'decimal:2',
        'interest_amount' => 'decimal:2',
        'late_fee_amount' => 'decimal:2',
        'insurance_amount' => 'decimal:2',
        'legal_fee_amount' => 'decimal:2',
        'commission_amount' => 'decimal:2',
        'balance_before' => 'decimal:2',
        'balance_after' => 'decimal:2',
    ];

    public function loan(): BelongsTo
    {
        return $this->belongsTo(Loan::class);
    }

    public function installment(): BelongsTo
    {
        return $this->belongsTo(LoanInstallment::class, 'loan_installment_id');
    }
}
