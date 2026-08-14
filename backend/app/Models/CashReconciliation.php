<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CashReconciliation extends Model
{
    use HasFactory;

    protected $fillable = [
        'module_id',
        'date',
        'exchange_rate',
        'total_local_currency',
        'total_foreign_currency',
        'total_general',
        'total_expenses',
        'difference',
        'status',
        'user_id',
        'is_deposited',
        'deposit_account_id',
        'deposit_date',
        'deposit_amount',
        'deposit_difference',
        'notes',
    ];

    protected $casts = [
        'date' => 'date',
        'exchange_rate' => 'decimal:4',
        'total_local_currency' => 'decimal:2',
        'total_foreign_currency' => 'decimal:2',
        'total_general' => 'decimal:2',
        'total_expenses' => 'decimal:2',
        'difference' => 'decimal:2',
    ];

    public function module()
    {
        return $this->belongsTo(Module::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(CashTransaction::class);
    }

    public function denominations()
    {
        return $this->hasMany(ReconciliationDenomination::class);
    }

    public function depositAccount()
    {
        return $this->belongsTo(AccountingAccount::class, 'deposit_account_id');
    }
}
