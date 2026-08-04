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
        Schema::create('accounting_accounts', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('name');
            $table->enum('type', ['Activo', 'Pasivo', 'Capital', 'Ingreso', 'Costo', 'Gasto']);
            $table->foreignId('parent_id')->nullable()->constrained('accounting_accounts')->nullOnDelete();
            $table->boolean('is_transactional')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('accounting_accounts');
    }
};
