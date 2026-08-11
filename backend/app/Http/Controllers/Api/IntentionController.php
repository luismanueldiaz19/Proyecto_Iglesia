<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\Intention;
use Illuminate\Support\Facades\Storage;

class IntentionController extends Controller
{
    /**
     * Listar intenciones (puede ser filtrado por status)
     */
    public function index(Request $request)
    {
        $query = Intention::query();
        
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Ordenamos para que las pendientes más antiguas salgan primero
        $intentions = $query->orderBy('created_at', 'asc')->get();

        return response()->json([
            'status' => 'success',
            'data' => $intentions
        ]);
    }

    /**
     * Endpoint público o webhook para recibir intención desde el bot de WhatsApp
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'nullable|string|max:255',
            'concept' => 'required|string',
            'intention_date' => 'nullable|date',
            'amount' => 'required|numeric|min:0',
            'payment_method' => 'nullable|string',
            'payment_receipt' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:5120', // Hasta 5MB para fotos
        ]);

        $data = $request->except('payment_receipt');
        
        // Guardar la foto si viene adjunta
        if ($request->hasFile('payment_receipt')) {
            $path = $request->file('payment_receipt')->store('receipts', 'public');
            $data['payment_receipt_path'] = $path;
        }

        $data['status'] = 'pendiente';
        $data['payment_status'] = 'pendiente';

        $intention = Intention::create($data);

        return response()->json([
            'status' => 'success',
            'message' => 'Intención registrada correctamente. Pendiente por confirmar.',
            'data' => $intention
        ], 201);
    }

    /**
     * Aprobar una intención y marcar su pago como completado
     */
    public function approve($id)
    {
        $intention = Intention::findOrFail($id);
        
        $intention->status = 'aprobado';
        $intention->payment_status = 'pagado';
        $intention->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Intención aprobada correctamente.',
            'data' => $intention
        ]);
    }
}
