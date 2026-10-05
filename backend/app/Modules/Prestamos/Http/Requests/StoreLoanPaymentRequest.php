<?php

namespace App\Modules\Prestamos\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLoanPaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'loan_id' => 'required|exists:loans,id',
            'loan_installment_id' => 'nullable|exists:loan_installments,id',
            'bank_account_id' => 'nullable|exists:bank_accounts,id',
            'transaction_date' => 'required|date',
            'reference_type' => 'nullable|string|max:50',
            'reference_number' => 'nullable|string|max:50',
            'concept' => 'nullable|string|max:255',
            'total_paid' => 'required|numeric|min:0',
            'capital_amount' => 'nullable|numeric|min:0',
            'interest_amount' => 'nullable|numeric|min:0',
            'late_fee_amount' => 'nullable|numeric|min:0',
            'insurance_amount' => 'nullable|numeric|min:0',
            'legal_fee_amount' => 'nullable|numeric|min:0',
            'commission_amount' => 'nullable|numeric|min:0',
            'voucher_path' => 'nullable|string|max:255',
        ];
    }
}
