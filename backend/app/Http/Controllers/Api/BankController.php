<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Bank;

class BankController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $banks = Bank::all();
        return response()->json($banks);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'nullable|string|max:50',
            'is_active' => 'boolean',
        ]);

        $bank = Bank::create($validated);
        return response()->json($bank, 201);
    }

    public function show(string $id)
    {
        $bank = Bank::findOrFail($id);
        return response()->json($bank);
    }

    public function update(Request $request, string $id)
    {
        $bank = Bank::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'code' => 'nullable|string|max:50',
            'is_active' => 'boolean',
        ]);

        $bank->update($validated);
        return response()->json($bank);
    }

    public function destroy(string $id)
    {
        $bank = Bank::findOrFail($id);
        $bank->delete();
        return response()->json(null, 204);
    }
}
