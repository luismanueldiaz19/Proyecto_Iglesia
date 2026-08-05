<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IngresoProvicional extends Model
{
    protected $fillable = [
        'fecha_ingreso',
        'concepto',
        'monto',
        'usuario_registro'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'usuario_registro');
    }
}
