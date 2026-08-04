<?php
namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Log;

class Handler extends ExceptionHandler
{
    // ...
    public function render($request, Throwable $e)
    {
        if ($e instanceof ValidationException) {
            Log::error('Validation Failed', ['request' => $request->all(), 'errors' => $e->errors()]);
        }
        return parent::render($request, $e);
    }
}
