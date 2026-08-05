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
        'usuario_registro'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'usuario_registro');
    }
}
