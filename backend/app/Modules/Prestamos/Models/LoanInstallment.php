<?php

namespace App\Modules\Prestamos\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LoanInstallment extends Model
{
    protected $fillable = [
        'loan_id',
        'installment_number',
        'due_date',
        'expected_capital',
        'expected_interest',
        'expected_insurance',
        'expected_total',
        'paid_capital',
        'paid_interest',
        'paid_insurance',
        'paid_late_fee',
        'paid_total',
        'status',
    ];

    protected $casts = [
        'due_date' => 'date',
        'expected_capital' => 'decimal:2',
        'expected_interest' => 'decimal:2',
        'expected_insurance' => 'decimal:2',
        'expected_total' => 'decimal:2',
        'paid_capital' => 'decimal:2',
        'paid_interest' => 'decimal:2',
        'paid_insurance' => 'decimal:2',
        'paid_late_fee' => 'decimal:2',
        'paid_total' => 'decimal:2',
    ];

    public function loan(): BelongsTo
    {
        return $this->belongsTo(Loan::class);
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(LoanTransaction::class);
    }
}
