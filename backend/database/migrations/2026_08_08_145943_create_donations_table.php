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
        Schema::create('donations', function (Blueprint $table) {
            $table->id();
            $table->string('donor_name');
            $table->string('donor_phone')->nullable();
            $table->string('donor_cedula')->nullable();
            $table->string('donor_rnc')->nullable();
            $table->boolean('with_receipt')->default(false);
            $table->string('payment_method')->default('Efectivo');
            $table->string('concept');
            $table->decimal('amount', 12, 2);
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('donations');
    }
};
