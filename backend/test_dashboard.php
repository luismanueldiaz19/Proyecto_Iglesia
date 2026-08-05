<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$req = new \Illuminate\Http\Request(['start_date'=>'2026-01-01', 'end_date'=>'2026-12-31']);
$ctrl = new \App\Http\Controllers\ProvicionalDashboardController();
echo json_encode($ctrl->index($req)->getData());
