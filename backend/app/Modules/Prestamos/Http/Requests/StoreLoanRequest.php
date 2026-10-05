<?php

namespace App\Modules\Prestamos\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLoanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'lender_name' => 'required|string|max:255',
            'loan_number' => 'required|string|max:50',
            'member_number' => 'nullable|string|max:50',
            'debtor_name' => 'nullable|string|max:255',
            'default_bank_account_id' => 'nullable|exists:bank_accounts,id',
            'start_date' => 'required|date',
            'due_date' => 'nullable|date|after_or_equal:start_date',
            'original_amount' => 'required|numeric|min:0',
            'current_balance' => 'nullable|numeric|min:0',
            'monthly_rate' => 'nullable|numeric|min:0',
            'annual_rate' => 'nullable|numeric|min:0',
            'term_months' => 'nullable|integer|min:1',
            'installment_amount' => 'nullable|numeric|min:0',
            'modality' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
        ];
    }
}
