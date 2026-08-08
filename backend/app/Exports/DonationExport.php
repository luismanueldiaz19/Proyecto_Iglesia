<?php

namespace App\Exports;

use App\Models\Donation;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class DonationExport implements FromCollection, WithHeadings, WithMapping
{
    protected $startDate;
    protected $endDate;
    protected $search;
    protected $paymentMethod;

    public function __construct($startDate = null, $endDate = null, $search = null, $paymentMethod = null)
    {
        $this->startDate = $startDate;
        $this->endDate = $endDate;
        $this->search = $search;
        $this->paymentMethod = $paymentMethod;
    }

    public function collection()
    {
        $query = Donation::with('user')->orderBy('id', 'desc');

        if ($this->startDate) {
            $query->whereDate('created_at', '>=', $this->startDate);
        }
        if ($this->endDate) {
            $query->whereDate('created_at', '<=', $this->endDate);
        }
        if ($this->paymentMethod) {
            $query->where('payment_method', $this->paymentMethod);
        }
        if ($this->search) {
            $searchTerm = '%' . $this->search . '%';
            $query->where(function ($q) use ($searchTerm) {
                $q->where('donor_name', 'ilike', $searchTerm)
                  ->orWhere('concept', 'ilike', $searchTerm)
                  ->orWhere('donor_cedula', 'ilike', $searchTerm);
            });
        }

        return $query->get();
    }

    public function headings(): array
    {
        return [
            'No. Recibo',
            'Fecha',
            'Donante',
            'Teléfono',
            'Cédula',
            'Concepto',
            'Método Pago',
            'Registrado Por',
            'Monto',
        ];
    }

    public function map($donation): array
    {
        return [
            $donation->id,
            $donation->created_at->format('Y-m-d H:i:s'),
            $donation->donor_name,
            $donation->donor_phone,
            $donation->donor_cedula,
            $donation->concept,
            $donation->payment_method,
            $donation->user ? $donation->user->name : 'N/A',
            $donation->amount,
        ];
    }
}
