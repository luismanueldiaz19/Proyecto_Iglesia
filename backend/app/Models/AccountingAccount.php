<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AccountingAccount extends Model
{
    protected $fillable = [
        'code',
        'name',
        'type',
        'parent_id',
        'is_transactional',
    ];

    protected $casts = [
        'is_transactional' => 'boolean',
    ];

    public function parent()
    {
        return $this->belongsTo(AccountingAccount::class, 'parent_id');
    }

    public function children()
    {
        return $this->hasMany(AccountingAccount::class, 'parent_id');
    }
}
