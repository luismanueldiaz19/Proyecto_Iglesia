<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BankAccount extends Model
{
    use HasFactory;

    protected $fillable = [
        'bank_id',
        'name',
        'account_number',
        'currency',
        'current_balance',
        'accounting_account_id',
        'is_active',
    ];

    public function bank()
    {
        return $this->belongsTo(Bank::class);
    }

    public function accountingAccount()
    {
        return $this->belongsTo(AccountingAccount::class);
    }

    public function transactions()
    {
        return $this->hasMany(BankTransaction::class);
    }

    public function reconciliations()
    {
        return $this->hasMany(BankReconciliation::class);
    }
}
