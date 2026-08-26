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
use App\Http\Controllers\UserController;
use App\Http\Controllers\DonationController;
use App\Http\Controllers\IngresoProvicionalController;
use App\Http\Controllers\GastoProvicionalController;
use App\Http\Controllers\ProvicionalDashboardController;
use App\Http\Controllers\ProvicionalReportController;
use App\Http\Controllers\Api\BankController;
use App\Http\Controllers\Api\BankAccountController;
use App\Http\Controllers\Api\BankTransactionController;
use App\Http\Controllers\Api\BankReconciliationController;
use App\Http\Controllers\Api\IntentionController;
use App\Http\Controllers\ProfileController;

Route::post('/login', [AuthController::class, 'login']);

// Webhook para Chatbot (público por ahora, se puede asegurar con un API Key después)
Route::post('/webhook/intentions', [IntentionController::class, 'store']);

// Ruta pública para descargar PDF con URL firmada
Route::get('/cash-reconciliations/template/download-pdf', [CashReconciliationController::class, 'generateTemplatePdf'])
    ->name('cash-reconciliation.template.pdf')
    ->middleware('signed');

Route::get('/cash-reconciliations/all/download-pdf', [CashReconciliationController::class, 'generateAllPdf'])
    ->name('cash-reconciliation.all.pdf')
    ->middleware('signed');

Route::get('/cash-reconciliations/{id}/download-pdf', [CashReconciliationController::class, 'generatePdf'])
    ->name('cash-reconciliation.pdf')
    ->middleware('signed');

Route::get('/donations/{id}/download-pdf', [DonationController::class, 'generatePdf'])
    ->name('donation.pdf')
    ->middleware('signed');

Route::get('/provicional-dashboard/download-pdf', [ProvicionalDashboardController::class, 'exportPdf'])
    ->name('provicional-dashboard.pdf')
    ->middleware('signed');

Route::get('/provicional-reportes/download-pdf', [ProvicionalReportController::class, 'exportPdf'])
    ->name('provicional-reportes.pdf')
    ->middleware('signed');

Route::get('/provicional-reportes/download-excel', [ProvicionalReportController::class, 'exportExcel'])
    ->name('provicional-reportes.excel')
    ->middleware('signed');



// Rutas protegidas por Sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    Route::apiResource('users', UserController::class);

    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Perfil
    Route::put('/profile', [ProfileController::class, 'updateProfile']);
    Route::put('/profile/password', [ProfileController::class, 'changePassword']);
    Route::post('/profile/photo', [ProfileController::class, 'uploadPhoto']);
    Route::get('/profile/photo/{filename}', [ProfileController::class, 'getPhoto']);
    Route::get('/profile/sessions', [ProfileController::class, 'getSessions']);
    Route::get('/profile/permissions', [ProfileController::class, 'getPermissions']);

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
    
    Route::get('/cash-reconciliations/all', [CashReconciliationController::class, 'all']);
    Route::get('/cash-reconciliations/all/pdf', [CashReconciliationController::class, 'generateAllPdf']);
    Route::get('/cash-reconciliations/all/pdf-url', [CashReconciliationController::class, 'getAllPdfUrl']);
    
    Route::get('/cash-reconciliations/template/pdf-url', [CashReconciliationController::class, 'getTemplatePdfUrl']);
    
    Route::get('/cash-reconciliations/{id}', [CashReconciliationController::class, 'show']);
    Route::get('/cash-reconciliations/{id}/pdf-url', [CashReconciliationController::class, 'getPdfUrl']);
    
    Route::get('/cash-reconciliations/current/{moduleId}', [CashReconciliationController::class, 'current']);
    Route::post('/cash-reconciliations', [CashReconciliationController::class, 'store']);
    Route::post('/cash-reconciliations/{id}/close', [CashReconciliationController::class, 'close']);
    Route::post('/cash-reconciliations/{id}/deposit', [CashReconciliationController::class, 'deposit']);
    
    Route::post('/cash-transactions', [CashTransactionController::class, 'store']);
    Route::put('/cash-transactions/{id}', [CashTransactionController::class, 'update']);
    
    // Ingresos y Gastos Provisionales
    Route::get('ingresos-provicionales-chart', [IngresoProvicionalController::class, 'chartData']);
    Route::apiResource('ingresos-provicionales', IngresoProvicionalController::class);
    Route::post('ingresos-provicionales/preview-import', [IngresoProvicionalController::class, 'previewImportExcel']);
    Route::post('ingresos-provicionales/import', [IngresoProvicionalController::class, 'importExcel']);
    
    Route::get('gastos-provicionales-chart', [GastoProvicionalController::class, 'chartData']);
    Route::apiResource('gastos-provicionales', GastoProvicionalController::class);
    Route::post('gastos-provicionales/preview-import', [GastoProvicionalController::class, 'previewImportExcel']);
    Route::post('gastos-provicionales/import', [GastoProvicionalController::class, 'importExcel']);
    
    // Dashboard y Reportes
    Route::get('provicional-dashboard', [ProvicionalDashboardController::class, 'index']);
    Route::get('provicional-dashboard/pdf-url', [ProvicionalDashboardController::class, 'getPdfUrl']);
    Route::get('provicional-reportes', [ProvicionalReportController::class, 'index']);
    Route::get('provicional-reportes/pdf-url', [ProvicionalReportController::class, 'getPdfUrl']);
    Route::get('provicional-reportes/excel-url', [ProvicionalReportController::class, 'getExcelUrl']);

    // Donaciones
    Route::get('donations', [DonationController::class, 'index']);
    Route::post('donations', [DonationController::class, 'store']);
    Route::get('donations/{id}/pdf-url', [DonationController::class, 'getPdfUrl']);
    
    // Rutas para historial y reportes de donaciones
    Route::get('donations-chart', [DonationController::class, 'chartData']);
    Route::get('donations/export/pdf', [DonationController::class, 'exportPdf']);
    Route::get('donations/export/excel', [DonationController::class, 'exportExcel']);

    // Módulo de Bancos y Conciliaciones
    Route::apiResource('banks', BankController::class);
    Route::apiResource('bank-accounts', BankAccountController::class);
    Route::apiResource('bank-transactions', BankTransactionController::class);
    Route::apiResource('bank-reconciliations', BankReconciliationController::class);

    // Intenciones
    Route::get('intentions', [IntentionController::class, 'index']);
    Route::put('intentions/{id}/approve', [IntentionController::class, 'approve']);
});
