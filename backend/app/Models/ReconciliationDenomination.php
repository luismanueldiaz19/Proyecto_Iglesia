<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReconciliationDenomination extends Model
{
    use HasFactory;

    protected $fillable = [
        'cash_reconciliation_id',
        'denomination_id',
        'quantity',
        'total',
    ];

    protected $casts = [
        'total' => 'decimal:2',
    ];

    public function reconciliation()
    {
        return $this->belongsTo(CashReconciliation::class, 'cash_reconciliation_id');
    }

    public function denomination()
    {
        return $this->belongsTo(Denomination::class);
    }
}
