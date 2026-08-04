<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$v = Illuminate\Support\Facades\Validator::make(['account_id'=>4, 'amount'=>20000], ['account_id'=>'required|exists:accounting_accounts,id']);
echo json_encode(['fails' => $v->fails(), 'errors' => $v->errors()]);
