<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Agrega columnas de trazabilidad para identificar si un ingreso provicional
     * fue registrado manualmente o como depósito de un cuadre de caja.
     *
     * Los ingresos provenientes de cuadre SÍ generan movimiento bancario
     * (el depósito físico al banco se registra en bank_transactions).
     */
    public function up(): void
    {
        Schema::table('ingreso_provicionals', function (Blueprint $table) {
            // Relación directa con el cuadre de caja que originó este depósito
            $table->foreignId('cash_reconciliation_id')
                  ->nullable()
                  ->constrained('cash_reconciliations')
                  ->nullOnDelete()
                  ->after('usuario_registro');

            // Identifica el origen del ingreso:
            //   'manual'  → registrado desde el formulario de ingresos
            //   'cuadre'  → registrado automáticamente al depositar un cuadre de caja
            $table->enum('origen', ['manual', 'cuadre'])
                  ->default('manual')
                  ->after('cash_reconciliation_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('ingreso_provicionals', function (Blueprint $table) {
            $table->dropForeign(['cash_reconciliation_id']);
            $table->dropColumn(['cash_reconciliation_id', 'origen']);
        });
    }
};
