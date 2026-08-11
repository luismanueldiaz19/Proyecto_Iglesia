<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Intention extends Model
{
    protected $fillable = [
        'name',
        'concept',
        'intention_date',
        'phone',
        'email',
        'amount',
        'payment_method',
        'payment_status',
        'status',
        'payment_receipt_path'
    ];

    protected $casts = [
        'intention_date' => 'date',
        'amount' => 'decimal:2',
    ];
}
