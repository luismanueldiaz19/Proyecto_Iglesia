<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Denomination extends Model
{
    use HasFactory;

    protected $fillable = [
        'value',
        'type',
        'currency',
    ];

    protected $casts = [
        'value' => 'decimal:2',
    ];
}
