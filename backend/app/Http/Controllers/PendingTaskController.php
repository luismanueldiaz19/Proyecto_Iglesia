<?php

namespace App\Http\Controllers;

use App\Models\PendingTask;
use Illuminate\Http\Request;

class PendingTaskController extends Controller
{
    public function index()
    {
        $tasks = PendingTask::with('user:id,name,username')
            ->orderBy('id', 'desc')
            ->get();
        return response()->json($tasks);
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'details' => 'required|string',
            'plan_date' => 'required|date',
            'completed_date' => 'nullable|date',
            'status' => 'nullable|string|in:Pendiente,Terminado',
            'comments' => 'nullable|string',
        ]);

        $task = PendingTask::create([
            'title' => $request->title,
            'details' => $request->details,
            'plan_date' => $request->plan_date,
            'completed_date' => $request->completed_date,
            'status' => $request->status ?? 'Pendiente',
            'comments' => $request->comments,
            'registered_by' => $request->user()->id,
        ]);

        return response()->json($task->load('user:id,name,username'), 201);
    }

    public function show($id)
    {
        $task = PendingTask::with('user:id,name,username')->findOrFail($id);
        return response()->json($task);
    }

    public function update(Request $request, $id)
    {
        $task = PendingTask::findOrFail($id);

        $request->validate([
            'title' => 'required|string|max:255',
            'details' => 'required|string',
            'plan_date' => 'required|date',
            'completed_date' => 'nullable|date',
            'status' => 'nullable|string|in:Pendiente,Terminado',
            'comments' => 'nullable|string',
        ]);

        $task->update([
            'title' => $request->title,
            'details' => $request->details,
            'plan_date' => $request->plan_date,
            'completed_date' => $request->completed_date,
            'status' => $request->status ?? 'Pendiente',
            'comments' => $request->comments,
        ]);

        return response()->json($task->load('user:id,name,username'));
    }

    public function destroy($id)
    {
        $task = PendingTask::findOrFail($id);
        $task->delete();
        return response()->json(['message' => 'Task deleted successfully']);
    }

    public function getPdfUrl(Request $request)
    {
        $url = \Illuminate\Support\Facades\URL::temporarySignedRoute(
            'pending-tasks.pdf',
            now()->addMinutes(30),
            $request->all()
        );

        return response()->json(['url' => $url]);
    }

    public function downloadPdf(Request $request)
    {
        $query = PendingTask::with('user:id,name,username')->orderBy('id', 'desc');

        if ($request->filled('month')) {
            $query->whereMonth('plan_date', $request->month);
            if ($request->filled('year')) {
                $query->whereYear('plan_date', $request->year);
            }
        }

        if ($request->filled('status') && $request->status !== 'Todos') {
            $query->where('status', $request->status);
        }

        // Apply text search if needed (basic version)
        if ($request->filled('search')) {
            $search = strtolower($request->search);
            $query->where(function($q) use ($search) {
                $q->where('title', 'LIKE', "%{$search}%")
                  ->orWhere('details', 'LIKE', "%{$search}%");
            });
        }

        $tasks = $query->get();

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.pending_tasks', compact('tasks'));
        return $pdf->stream('tareas_pendientes_' . date('Y_m_d') . '.pdf');
    }
}
