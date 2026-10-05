<?php

namespace App\Modules\Prestamos\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Loan extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'lender_name',
        'loan_number',
        'member_number',
        'debtor_name',
        'default_bank_account_id',
        'start_date',
        'due_date',
        'original_amount',
        'current_balance',
        'monthly_rate',
        'annual_rate',
        'term_months',
        'installment_amount',
        'modality',
        'status',
        'notes',
    ];

    protected $casts = [
        'start_date' => 'date',
        'due_date' => 'date',
        'original_amount' => 'decimal:2',
        'current_balance' => 'decimal:2',
        'monthly_rate' => 'decimal:3',
        'annual_rate' => 'decimal:3',
        'installment_amount' => 'decimal:2',
    ];

    public function installments(): HasMany
    {
        return $this->hasMany(LoanInstallment::class)->orderBy('installment_number');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(LoanTransaction::class)->orderByDesc('transaction_date');
    }
}
