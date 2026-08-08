<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Bank;
use App\Models\AccountingAccount;

class BankAccountSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $bank = Bank::where('code', 'CG')->first();
        $accountingAccount = AccountingAccount::where('code', '1101')->first();

        if ($bank && $accountingAccount) {
            DB::table('bank_accounts')->insertOrIgnore([
                'bank_id' => $bank->id,
                'name' => 'Caja General',
                'account_number' => '0000001',
                'currency' => 'DOP',
                'current_balance' => 0,
                'accounting_account_id' => $accountingAccount->id,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
