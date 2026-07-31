<?php

namespace App\Http\Controllers;

use App\Models\JournalEntryLine;
use Illuminate\Http\Request;

class AccountingReportController extends Controller
{
    public function ledger($accountId)
    {
        // Obtener todas las líneas para esa cuenta y cargar su asiento principal
        $lines = JournalEntryLine::with('journalEntry')
            ->where('account_id', $accountId)
            ->join('journal_entries', 'journal_entry_lines.journal_entry_id', '=', 'journal_entries.id')
            ->orderBy('journal_entries.date', 'asc')
            ->orderBy('journal_entries.id', 'asc')
            ->select('journal_entry_lines.*')
            ->get();
            
        return response()->json($lines);
    }
}
