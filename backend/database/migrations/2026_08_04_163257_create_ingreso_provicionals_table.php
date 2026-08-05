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
        Schema::create('ingreso_provicionals', function (Blueprint $table) {
            $table->id();
            $table->date('fecha_ingreso');
            $table->string('concepto');
            $table->decimal('monto', 15, 2);
            $table->foreignId('usuario_registro')->constrained('users');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ingreso_provicionals');
    }
};
