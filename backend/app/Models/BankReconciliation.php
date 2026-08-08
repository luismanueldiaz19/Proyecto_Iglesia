<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BankReconciliation extends Model
{
    use HasFactory;

    protected $fillable = [
        'bank_account_id',
        'statement_date',
        'statement_balance',
        'reconciled_by',
        'status',
        'notes',
    ];

    public function bankAccount()
    {
        return $this->belongsTo(BankAccount::class);
    }

    public function reconciledBy()
    {
        return $this->belongsTo(User::class, 'reconciled_by');
    }

    public function transactions()
    {
        return $this->belongsToMany(BankTransaction::class, 'bank_reconciliation_bank_transaction');
    }
}
