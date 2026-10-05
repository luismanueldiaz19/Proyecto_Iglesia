<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('loan_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('loan_id')->constrained('loans')->cascadeOnDelete();
            $table->foreignId('loan_installment_id')->nullable()->constrained('loan_installments')->nullOnDelete();
            
            // Vínculo con transacciones bancarias o cajas si aplica
            $table->unsignedBigInteger('bank_account_id')->nullable();
            $table->unsignedBigInteger('bank_transaction_id')->nullable();
            
            $table->date('transaction_date'); // Fecha aplicada en la cooperativa
            $table->string('reference_type')->nullable(); // 'RI' (Recibo Ingreso Caja), 'NC' (Nota Crédito), 'CK' (Cheque)
            $table->string('reference_number')->nullable(); // Ej: 5286, 138899, Ck.56
            $table->string('concept')->nullable(); // Ej: "PAGO PRESTAMO DESDE CUENTA DE AHORROS"
            
            // Monto Total Pagado
            $table->decimal('total_paid', 15, 2);
            
            // Desglose del pago
            $table->decimal('capital_amount', 15, 2)->default(0); // Capital amortizado
            $table->decimal('interest_amount', 15, 2)->default(0); // Interés ordinario
            $table->decimal('late_fee_amount', 15, 2)->default(0); // Mora
            $table->decimal('insurance_amount', 15, 2)->default(0); // Seguro
            $table->decimal('legal_fee_amount', 15, 2)->default(0); // Cargos legales
            $table->decimal('commission_amount', 15, 2)->default(0); // Comisiones
            
            // Trazabilidad de saldo de capital
            $table->decimal('balance_before', 15, 2);
            $table->decimal('balance_after', 15, 2);
            
            $table->string('voucher_path')->nullable(); // Soporte escaneado
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loan_transactions');
    }
};
