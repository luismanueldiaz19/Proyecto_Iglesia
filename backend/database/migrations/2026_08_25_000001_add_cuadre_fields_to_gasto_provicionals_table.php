<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Agrega columnas de trazabilidad para identificar si un gasto provicional
     * fue registrado manualmente (formulario) o desde un cuadre de caja.
     *
     * Los gastos provenientes de cuadre NO afectan cuentas bancarias.
     */
    public function up(): void
    {
        Schema::table('gasto_provicionals', function (Blueprint $table) {
            // Relación directa con la transacción de caja que lo originó (solo cuadres)
            $table->foreignId('cash_transaction_id')
                  ->nullable()
                  ->constrained('cash_transactions')
                  ->nullOnDelete()
                  ->after('usuario_registro');

            // Identifica el origen del gasto:
            //   'manual'  → registrado desde el formulario de gastos (afecta banco)
            //   'cuadre'  → registrado desde el cuadre de caja (NO afecta banco)
            $table->enum('origen', ['manual', 'cuadre'])
                  ->default('manual')
                  ->after('cash_transaction_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('gasto_provicionals', function (Blueprint $table) {
            $table->dropForeign(['cash_transaction_id']);
            $table->dropColumn(['cash_transaction_id', 'origen']);
        });
    }
};
