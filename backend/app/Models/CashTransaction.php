<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CashTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'cash_reconciliation_id',
        'account_id',
        'description',
        'amount',
        'type',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    public function reconciliation()
    {
        return $this->belongsTo(CashReconciliation::class, 'cash_reconciliation_id');
    }

    public function account()
    {
        return $this->belongsTo(AccountingAccount::class, 'account_id');
    }

    /**
     * Gasto provisional que fue creado automáticamente desde este gasto de cuadre.
     * Solo existe cuando la transacción es de tipo 'expense'.
     */
    public function gastoProvicional()
    {
        return $this->hasOne(GastoProvicional::class, 'cash_transaction_id');
    }
}
