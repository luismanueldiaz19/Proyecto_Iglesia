<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PendingTask extends Model
{
    protected $fillable = [
        'title',
        'details',
        'plan_date',
        'completed_date',
        'status',
        'comments',
        'registered_by',
    ];

    protected $casts = [
        'plan_date' => 'date',
        'completed_date' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'registered_by');
    }
}
