<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('accounting_engine_configs', function (Blueprint $table) {
            $table->id();
            $table->string('operation_code')->unique(); // e.g., 'VENTA_LIBRERIA'
            $table->string('name'); // Name of the operation, e.g., "Venta de Librería"
            $table->foreignId('debit_account_id')->constrained('accounting_accounts');
            $table->foreignId('credit_account_id')->constrained('accounting_accounts');
            $table->foreignId('tax_account_id')->nullable()->constrained('accounting_accounts');
            $table->decimal('tax_percentage', 5, 2)->default(0); // e.g., 18.00
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('accounting_engine_configs');
    }
};
