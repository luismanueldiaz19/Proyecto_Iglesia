<?php

namespace App\Http\Controllers;

use App\Models\Denomination;
use Illuminate\Http\Request;

class DenominationController extends Controller
{
    public function index()
    {
        // Ordenados por valor de mayor a menor para la UI de cuadre
        return response()->json(Denomination::orderBy('value', 'desc')->get());
    }
}
