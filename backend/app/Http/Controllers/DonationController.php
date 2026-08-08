<?php

namespace App\Http\Controllers;

use App\Models\Donation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;
use Barryvdh\DomPDF\Facade\Pdf;

class DonationController extends Controller
{
    public function index(Request $request)
    {
        $query = Donation::with('user')->orderBy('id', 'desc');

        if ($request->filled('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }

        if ($request->filled('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }
        
        if ($request->filled('payment_method')) {
            $query->where('payment_method', $request->payment_method);
        }
        
        if ($request->filled('search')) {
            $searchTerm = '%' . $request->search . '%';
            $query->where(function ($q) use ($searchTerm) {
                $q->where('donor_name', 'ilike', $searchTerm)
                  ->orWhere('concept', 'ilike', $searchTerm)
                  ->orWhere('donor_cedula', 'ilike', $searchTerm);
            });
        }

        if ($request->has('page')) {
            $donations = $query->paginate(50);
        } else {
            $donations = $query->get();
        }

        return response()->json($donations);
    }

    public function chartData()
    {
        $year = date('Y');
        
        $data = Donation::selectRaw("TO_CHAR(created_at, 'MM') as mes, SUM(amount) as total, COUNT(*) as cantidad")
            ->whereYear('created_at', $year)
            ->groupBy('mes')
            ->orderBy('mes')
            ->get();
            
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $request->validate([
            'donor_name' => 'required|string|max:255',
            'concept' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
        ]);

        $donation = Donation::create([
            'donor_name' => $request->donor_name,
            'donor_phone' => $request->donor_phone,
            'donor_cedula' => $request->donor_cedula,
            'donor_rnc' => $request->donor_rnc,
            'with_receipt' => $request->with_receipt ?? false,
            'payment_method' => $request->payment_method ?? 'Efectivo',
            'concept' => $request->concept,
            'amount' => $request->amount,
            'user_id' => $request->user()->id ?? null,
        ]);

        return response()->json($donation, 201);
    }

    public function getPdfUrl($id)
    {
        $url = URL::temporarySignedRoute(
            'donation.pdf',
            now()->addMinutes(30),
            ['id' => $id]
        );
        return response()->json(['url' => $url]);
    }

    public function generatePdf($id)
    {
        $donation = Donation::findOrFail($id);
        
        $pdf = Pdf::loadView('pdf.donation_invoice', compact('donation'));
        
        return $pdf->stream('recibo_donacion_' . $donation->id . '.pdf');
    }

    public function exportPdf(Request $request)
    {
        $query = Donation::with('user')->orderBy('id', 'desc');

        if ($request->filled('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }
        if ($request->filled('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        if ($request->filled('payment_method')) {
            $query->where('payment_method', $request->payment_method);
        }

        if ($request->filled('search')) {
            $searchTerm = '%' . $request->search . '%';
            $query->where(function ($q) use ($searchTerm) {
                $q->where('donor_name', 'ilike', $searchTerm)
                  ->orWhere('concept', 'ilike', $searchTerm)
                  ->orWhere('donor_cedula', 'ilike', $searchTerm);
            });
        }

        $donations = $query->get();
        
        $pdf = Pdf::loadView('reports.donations_list', compact('donations'));
        
        return $pdf->download('reporte_donaciones.pdf');
    }
    
    public function exportExcel(Request $request)
    {
        return \Maatwebsite\Excel\Facades\Excel::download(new \App\Exports\DonationExport($request->start_date, $request->end_date, $request->search, $request->payment_method), 'reporte_donaciones.xlsx');
    }
}
