<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('loan_installments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('loan_id')->constrained('loans')->cascadeOnDelete();
            
            $table->integer('installment_number'); // Cuota # 1 a 60
            $table->date('due_date');
            
            // Desglose proyectado / esperado
            $table->decimal('expected_capital', 15, 2)->default(0);
            $table->decimal('expected_interest', 15, 2)->default(0);
            $table->decimal('expected_insurance', 15, 2)->default(0);
            $table->decimal('expected_total', 15, 2)->default(0);
            
            // Montos cubiertos efectivamente
            $table->decimal('paid_capital', 15, 2)->default(0);
            $table->decimal('paid_interest', 15, 2)->default(0);
            $table->decimal('paid_insurance', 15, 2)->default(0);
            $table->decimal('paid_late_fee', 15, 2)->default(0);
            $table->decimal('paid_total', 15, 2)->default(0);
            
            $table->enum('status', ['pending', 'partial', 'paid', 'overdue'])->default('pending');
            $table->timestamps();
            
            $table->unique(['loan_id', 'installment_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loan_installments');
    }
};
