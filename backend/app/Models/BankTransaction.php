<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BankTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'bank_account_id',
        'date',
        'type',
        'amount',
        'reference',
        'description',
        'status',
        'journal_entry_id',
    ];

    public function bankAccount()
    {
        return $this->belongsTo(BankAccount::class);
    }

    public function journalEntry()
    {
        return $this->belongsTo(JournalEntry::class);
    }

    public function reconciliations()
    {
        return $this->belongsToMany(BankReconciliation::class, 'bank_reconciliation_bank_transaction');
    }
}
