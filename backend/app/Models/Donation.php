<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Donation extends Model
{
    use HasFactory;

    protected $fillable = [
        'donor_name',
        'donor_phone',
        'donor_cedula',
        'donor_rnc',
        'with_receipt',
        'payment_method',
        'concept',
        'amount',
        'user_id',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
