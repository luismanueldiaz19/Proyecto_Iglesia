<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GastoProvicional extends Model
{
    protected $fillable = [
        'fecha_gasto',
        'concepto',
        'num_check',
        'monto',
        'usuario_registro',
        'cash_transaction_id',
        'origen',
    ];

    /**
     * Relación con el usuario que registró el gasto.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'usuario_registro');
    }

    /**
     * Relación con la transacción de caja que originó este gasto.
     * Solo aplica cuando origen = 'cuadre'.
     */
    public function cashTransaction()
    {
        return $this->belongsTo(CashTransaction::class, 'cash_transaction_id');
    }
}
