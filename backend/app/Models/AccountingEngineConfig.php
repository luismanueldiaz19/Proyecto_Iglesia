<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AccountingEngineConfig extends Model
{
    use HasFactory;

    protected $fillable = [
        'operation_code',
        'name',
        'debit_account_id',
        'credit_account_id',
        'tax_account_id',
        'tax_percentage',
    ];

    public function debitAccount()
    {
        return $this->belongsTo(AccountingAccount::class, 'debit_account_id');
    }

    public function creditAccount()
    {
        return $this->belongsTo(AccountingAccount::class, 'credit_account_id');
    }

    public function taxAccount()
    {
        return $this->belongsTo(AccountingAccount::class, 'tax_account_id');
    }
}
