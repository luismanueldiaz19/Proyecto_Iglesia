# Prompt de Implementación: Módulo de Préstamos Institucionales (Pasivos)

## 1. Contexto y Objetivo
La institución tiene deudas y préstamos adquiridos con entidades financieras (por ejemplo, cooperativas de ahorro y crédito como CoopCupadec). Se requiere desarrollar un módulo de préstamos en Laravel con funcionamiento análogo al módulo de cuentas bancarias:
- Registrar préstamos adquiridos con sus condiciones iniciales (monto, plazo, tasa mensual/anual, cuota fija, fecha inicio y vencimiento).
- Mantener el saldo de capital actualizado en tiempo real.
- Registrar pagos/abonos desglosando con precisión:
  - Abono a Capital (reduce el pasivo/balance).
  - Interés corriente (gasto financiero).
  - Mora / Recargos (gasto por penalidad).
  - Seguro y comisiones/cargos legales.
- Conectar opcionalmente los egresos con el módulo de banco/caja existente de la institución.

---

## 2. Diagrama de Base de Datos y Migraciones

### 2.1 Migración: `create_loans_table.php`
```php
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
```

### 2.2 Migración: `create_loan_installments_table.php` (Tabla de Amortización)
```php
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
```

### 2.3 Migración: `create_loan_transactions_table.php` (Historial de Pagos y Movimientos)
```php
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
```

---

## 3. Modelos Eloquent

### 3.1 `App\Models\Loan.php`
```php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Loan extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'lender_name',
        'loan_number',
        'member_number',
        'debtor_name',
        'default_bank_account_id',
        'start_date',
        'due_date',
        'original_amount',
        'current_balance',
        'monthly_rate',
        'annual_rate',
        'term_months',
        'installment_amount',
        'modality',
        'status',
        'notes',
    ];

    protected $casts = [
        'start_date' => 'date',
        'due_date' => 'date',
        'original_amount' => 'decimal:2',
        'current_balance' => 'decimal:2',
        'monthly_rate' => 'decimal:3',
        'annual_rate' => 'decimal:3',
        'installment_amount' => 'decimal:2',
    ];

    public function installments(): HasMany
    {
        return $this->hasMany(LoanInstallment::class)->orderBy('installment_number');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(LoanTransaction::class)->orderByDesc('transaction_date');
    }
}
```

### 3.2 `App\Models\LoanTransaction.php`
```php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LoanTransaction extends Model
{
    protected $fillable = [
        'loan_id',
        'loan_installment_id',
        'bank_account_id',
        'bank_transaction_id',
        'transaction_date',
        'reference_type',
        'reference_number',
        'concept',
        'total_paid',
        'capital_amount',
        'interest_amount',
        'late_fee_amount',
        'insurance_amount',
        'legal_fee_amount',
        'commission_amount',
        'balance_before',
        'balance_after',
        'voucher_path',
    ];

    protected $casts = [
        'transaction_date' => 'date',
        'total_paid' => 'decimal:2',
        'capital_amount' => 'decimal:2',
        'interest_amount' => 'decimal:2',
        'late_fee_amount' => 'decimal:2',
        'insurance_amount' => 'decimal:2',
        'balance_before' => 'decimal:2',
        'balance_after' => 'decimal:2',
    ];

    public function loan(): BelongsTo
    {
        return $this->belongsTo(Loan::class);
    }

    public function installment(): BelongsTo
    {
        return $this->belongsTo(LoanInstallment::class, 'loan_installment_id');
    }
}
```

---

## 4. Servicio de Aplicación de Pago (`ApplyLoanPaymentService.php`)

```php
namespace App\Services;

use App\Models\Loan;
use App\Models\LoanTransaction;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

class ApplyLoanPaymentService
{
    public function execute(Loan $loan, array $data): LoanTransaction
    {
        return DB::transaction(function () use ($loan, $data) {
            $capital = (float) ($data['capital_amount'] ?? 0);
            $interest = (float) ($data['interest_amount'] ?? 0);
            $lateFee = (float) ($data['late_fee_amount'] ?? 0);
            $insurance = (float) ($data['insurance_amount'] ?? 0);
            $legalFee = (float) ($data['legal_fee_amount'] ?? 0);
            $commission = (float) ($data['commission_amount'] ?? 0);
            $totalPaid = (float) $data['total_paid'];

            // 1. Validar cuadre aritmético del pago
            $computedSum = round($capital + $interest + $lateFee + $insurance + $legalFee + $commission, 2);
            if (abs($computedSum - $totalPaid) > 0.01) {
                throw new InvalidArgumentException("La suma de los componentes ({$computedSum}) no coincide con el total pagado ({$totalPaid}).");
            }

            // 2. Control de balances
            $balanceBefore = (float) $loan->current_balance;
            $balanceAfter = round($balanceBefore - $capital, 2);

            if ($balanceAfter < 0) {
                throw new InvalidArgumentException("El abono a capital ({$capital}) excede el balance actual ({$balanceBefore}).");
            }

            // 3. Crear el movimiento
            $transaction = LoanTransaction::create([
                'loan_id' => $loan->id,
                'loan_installment_id' => $data['loan_installment_id'] ?? null,
                'bank_account_id' => $data['bank_account_id'] ?? null,
                'transaction_date' => $data['transaction_date'],
                'reference_type' => $data['reference_type'] ?? null,
                'reference_number' => $data['reference_number'] ?? null,
                'concept' => $data['concept'] ?? 'PAGO A PRESTAMO',
                'total_paid' => $totalPaid,
                'capital_amount' => $capital,
                'interest_amount' => $interest,
                'late_fee_amount' => $lateFee,
                'insurance_amount' => $insurance,
                'legal_fee_amount' => $legalFee,
                'commission_amount' => $commission,
                'balance_before' => $balanceBefore,
                'balance_after' => $balanceAfter,
                'voucher_path' => $data['voucher_path'] ?? null,
            ]);

            // 4. Actualizar el saldo del préstamo
            $newStatus = $balanceAfter <= 0 ? 'paid' : $loan->status;
            $loan->update([
                'current_balance' => $balanceAfter,
                'status' => $newStatus,
            ]);

            // 5. Integración Bancaria (Opcional)
            // Si el pago provino de una cuenta bancaria propia, registrar aquí el egreso en bank_transactions.

            return $transaction;
        });
    }
}
```

---

## 5. Instrucciones para el Agente AI que ejecute la tarea
1. Crear las 3 migraciones en orden de dependencia dentro de `database/migrations/`.
2. Crear los modelos en `app/Models/` con sus relaciones `hasMany` y `belongsTo`.
3. Implementar el servicio `App\Services\ApplyLoanPaymentService` asegurando el control transaccional mediante `DB::transaction`.
4. Crear un Request de validación (`StoreLoanPaymentRequest`) que verifique:
   - Que `loan_id` exista y esté activo.
   - Que `transaction_date` sea válida.
   - Que los montos numéricos sean mayores o iguales a 0.
5. Crear un endpoint o pantalla de resumen que muestre:
   - Resumen del Préstamo (Monto Inicial, Balance Actual, Tasa, Cuota esperada).
   - Tabla histórica de transacciones (idéntica al formato de los extractos bancarios y estados de cuenta cooperativos).