<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AccountingAccountController;
use App\Http\Controllers\CashReconciliationController;
use App\Http\Controllers\AccountingEngineConfigController;
use App\Http\Controllers\JournalEntryController;
use App\Http\Controllers\AccountingReportController;
use App\Http\Controllers\ModuleController;
use App\Http\Controllers\DenominationController;
use App\Http\Controllers\CashTransactionController;

Route::post('/login', [AuthController::class, 'login']);

// Ruta pública para descargar PDF con URL firmada
Route::get('/cash-reconciliations/{id}/download-pdf', [CashReconciliationController::class, 'generatePdf'])
    ->name('cash-reconciliation.pdf')
    ->middleware('signed');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Contabilidad
    Route::get('/accounts', [AccountingAccountController::class, 'index']);
    Route::post('/accounts', [AccountingAccountController::class, 'store']);
    Route::delete('/accounts/{id}', [AccountingAccountController::class, 'destroy']);

    Route::get('/accounting-configs', [AccountingEngineConfigController::class, 'index']);
    Route::post('/accounting-configs', [AccountingEngineConfigController::class, 'store']);
    Route::delete('/accounting-configs/{id}', [AccountingEngineConfigController::class, 'destroy']);

    // Finanzas / Reportes Contables
    Route::get('/journal-entries', [JournalEntryController::class, 'index']);
    Route::get('/ledger/{account_id}', [AccountingReportController::class, 'ledger']);

    // Caja (Cash)
    Route::get('/modules', [ModuleController::class, 'index']);
    Route::get('/modules/{moduleId}/reconciliations', [CashReconciliationController::class, 'index']);
    Route::get('/modules/{moduleId}/current-reconciliation', [CashReconciliationController::class, 'current']);
    Route::get('/denominations', [DenominationController::class, 'index']);
    
    Route::get('/cash-reconciliations/{id}', [CashReconciliationController::class, 'show']);
    Route::get('/cash-reconciliations/{id}/pdf-url', [CashReconciliationController::class, 'getPdfUrl']);
    
    Route::get('/cash-reconciliations/current/{moduleId}', [CashReconciliationController::class, 'current']);
    Route::post('/cash-reconciliations', [CashReconciliationController::class, 'store']);
    Route::post('/cash-reconciliations/{id}/close', [CashReconciliationController::class, 'close']);
    Route::post('/cash-reconciliations/{id}/deposit', [CashReconciliationController::class, 'deposit']);
    
    Route::post('/cash-transactions', [CashTransactionController::class, 'store']);
});
