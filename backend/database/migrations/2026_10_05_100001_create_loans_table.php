<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('loans', function (Blueprint $table) {
            $table->id();
            
            // Datos del Prestamista / Socio
            $table->string('lender_name'); // Ej: CoopCupadec
            $table->string('loan_number')->index(); // Ej: 96
            $table->string('member_number')->nullable(); // Ej: 151
            $table->string('debtor_name')->nullable(); // Ej: Centro de Evangelización Padre Fantino
            
            // Relación opcional con cuenta bancaria default de débito
            $table->unsignedBigInteger('default_bank_account_id')->nullable();
            // Foreign key si existe la tabla bank_accounts
            // $table->foreign('default_bank_account_id')->references('id')->on('bank_accounts')->nullOnDelete();
            
            // Condiciones Financieras
            $table->date('start_date');
            $table->date('due_date')->nullable();
            $table->decimal('original_amount', 15, 2); // Monto original recibido (ej: 2540415.96)
            $table->decimal('current_balance', 15, 2);  // Balance actual de capital pendiente
            
            $table->decimal('monthly_rate', 6, 3)->default(1.25); // Tasa mensual (ej: 1.25)
            $table->decimal('annual_rate', 6, 3)->nullable();
            $table->integer('term_months')->default(60); // Plazo en meses
            $table->decimal('installment_amount', 15, 2)->default(0); // Valor cuota regular (ej: 60436.32)
            $table->string('modality')->default('INTERES_CAPITAL_CUOTA_FIJA');
            
            // Estado: active, paid, restructured, in_default
            $table->enum('status', ['active', 'paid', 'restructured', 'in_default'])->default('active');
            $table->text('notes')->nullable();
            
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loans');
    }
};
