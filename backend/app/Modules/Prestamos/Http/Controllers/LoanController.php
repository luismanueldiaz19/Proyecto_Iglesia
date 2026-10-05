<?php

namespace App\Modules\Prestamos\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Prestamos\Models\Loan;
use App\Modules\Prestamos\Http\Requests\StoreLoanRequest;
use App\Modules\Prestamos\Http\Requests\StoreLoanPaymentRequest;
use App\Modules\Prestamos\Services\ApplyLoanPaymentService;
use Illuminate\Http\JsonResponse;

class LoanController extends Controller
{
    protected ApplyLoanPaymentService $applyLoanPaymentService;

    public function __construct(ApplyLoanPaymentService $applyLoanPaymentService)
    {
        $this->applyLoanPaymentService = $applyLoanPaymentService;
    }

    /**
     * Display a listing of the loans.
     */
    public function index(): JsonResponse
    {
        $loans = Loan::with('installments')->orderByDesc('created_at')->get();
        return response()->json($loans);
    }

    /**
     * Store a newly created loan in storage.
     */
    public function store(StoreLoanRequest $request): JsonResponse
    {
        $data = $request->validated();
        // El balance inicial puede venir del request o ser igual al monto original
        $data['current_balance'] = $data['current_balance'] ?? $data['original_amount'];
        $data['status'] = 'active';

        $loan = Loan::create($data);

        return response()->json([
            'message' => 'Préstamo creado exitosamente',
            'loan' => $loan
        ], 201);
    }

    /**
     * Update the specified loan in storage.
     */
    public function update(StoreLoanRequest $request, int $id): JsonResponse
    {
        $loan = Loan::findOrFail($id);
        $data = $request->validated();
        
        $loan->update($data);

        return response()->json([
            'message' => 'Préstamo actualizado exitosamente',
            'loan' => $loan
        ]);
    }

    /**
     * Display the specified loan along with transactions and installments.
     */
    public function show(int $id): JsonResponse
    {
        $loan = Loan::with(['installments', 'transactions'])->findOrFail($id);
        
        return response()->json($loan);
    }




    /**
     * Apply a payment to the loan.
     */
    public function applyPayment(int $id, StoreLoanPaymentRequest $request): JsonResponse
    {
        $loan = Loan::findOrFail($id);
        
        try {
            $transaction = $this->applyLoanPaymentService->execute($loan, $request->validated());
            
            return response()->json([
                'message' => 'Pago aplicado exitosamente',
                'transaction' => $transaction,
                'loan' => $loan->fresh()
            ]);
        } catch (\InvalidArgumentException $e) {
            return response()->json([
                'message' => 'Error de validación al aplicar pago',
                'error' => $e->getMessage()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Ocurrió un error al procesar el pago',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
