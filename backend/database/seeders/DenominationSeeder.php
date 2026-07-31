<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Denomination;

class DenominationSeeder extends Seeder
{
    public function run(): void
    {
        $denominations = [
            ['value' => 2000.00, 'type' => 'bill', 'currency' => 'DOP'],
            ['value' => 1000.00, 'type' => 'bill', 'currency' => 'DOP'],
            ['value' => 500.00, 'type' => 'bill', 'currency' => 'DOP'],
            ['value' => 200.00, 'type' => 'bill', 'currency' => 'DOP'],
            ['value' => 100.00, 'type' => 'bill', 'currency' => 'DOP'],
            ['value' => 50.00, 'type' => 'bill', 'currency' => 'DOP'],
            ['value' => 25.00, 'type' => 'coin', 'currency' => 'DOP'],
            ['value' => 10.00, 'type' => 'coin', 'currency' => 'DOP'],
            ['value' => 5.00, 'type' => 'coin', 'currency' => 'DOP'],
            ['value' => 1.00, 'type' => 'coin', 'currency' => 'DOP'],

            // USD - Dólares
            ['value' => 100.00, 'type' => 'bill', 'currency' => 'USD'],
            ['value' => 50.00, 'type' => 'bill', 'currency' => 'USD'],
            ['value' => 20.00, 'type' => 'bill', 'currency' => 'USD'],
            ['value' => 10.00, 'type' => 'bill', 'currency' => 'USD'],
            ['value' => 5.00, 'type' => 'bill', 'currency' => 'USD'],
            ['value' => 1.00, 'type' => 'bill', 'currency' => 'USD'],

            // EUR - Euros
            ['value' => 500.00, 'type' => 'bill', 'currency' => 'EUR'],
            ['value' => 200.00, 'type' => 'bill', 'currency' => 'EUR'],
            ['value' => 100.00, 'type' => 'bill', 'currency' => 'EUR'],
            ['value' => 50.00, 'type' => 'bill', 'currency' => 'EUR'],
            ['value' => 20.00, 'type' => 'bill', 'currency' => 'EUR'],
            ['value' => 10.00, 'type' => 'bill', 'currency' => 'EUR'],
            ['value' => 5.00, 'type' => 'bill', 'currency' => 'EUR'],
            ['value' => 2.00, 'type' => 'coin', 'currency' => 'EUR'],
            ['value' => 1.00, 'type' => 'coin', 'currency' => 'EUR'],
        ];

        foreach ($denominations as $denomination) {
            Denomination::updateOrCreate(
                [
                    'value' => $denomination['value'],
                    'type' => $denomination['type'],
                    'currency' => $denomination['currency'],
                ],
                $denomination
            );
        }
    }
}
