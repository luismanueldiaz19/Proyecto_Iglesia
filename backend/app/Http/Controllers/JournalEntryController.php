<?php

namespace App\Http\Controllers;

use App\Models\JournalEntry;
use Illuminate\Http\Request;

class JournalEntryController extends Controller
{
    public function index(Request $request)
    {
        $entries = JournalEntry::with('lines.account')
            ->orderBy('date', 'desc')
            ->orderBy('id', 'desc')
            ->paginate(50);
            
        return response()->json($entries);
    }
}
