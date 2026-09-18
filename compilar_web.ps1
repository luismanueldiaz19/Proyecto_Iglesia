Write-Host "Iniciando compilacion de Flutter Web..." -ForegroundColor Cyan
#comando para hacer la compilacion y hacer el push
# powershell -ExecutionPolicy Bypass -File .\compilar_web.ps1






# 1. Navegar al proyecto Flutter
Push-Location "$PSScriptRoot\comunidad_pfantino"

Write-Host "Ejecutando flutter clean..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Advertencia al ejecutar flutter clean, continuando..." -ForegroundColor DarkYellow
}

Write-Host "Ejecutando flutter pub get..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al obtener dependencias de Flutter." -ForegroundColor Red
    Pop-Location
    exit 1
}

# Compilar Flutter Web
flutter build web --release --no-tree-shake-icons
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error en la compilacion de Flutter Web." -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

Write-Host "Compilacion completada. Copiando archivos a Laravel..." -ForegroundColor Cyan

# Rutas
$buildWebDir = "$PSScriptRoot\comunidad_pfantino\build\web"
$publicDir = "$PSScriptRoot\backend\public"
$bladeViewPath = "$PSScriptRoot\backend\resources\views\app.blade.php"

# 2. Asegurar que las carpetas existen
if (-not (Test-Path $publicDir)) {
    New-Item -ItemType Directory -Path $publicDir -Force | Out-Null
}

# 3. Limpiar carpetas de compilaciones previas para evitar acumulación
$foldersToClean = @("assets", "canvaskit", "icons", "images")
foreach ($folder in $foldersToClean) {
    $targetFolder = Join-Path $publicDir $folder
    if (Test-Path $targetFolder) {
        Remove-Item -Recurse -Force $targetFolder
    }
}

# 4. Copiar todos los archivos de build/web a backend/public
Copy-Item -Path "$buildWebDir\*" -Destination $publicDir -Recurse -Force

# 5. Copiar index.html a app.blade.php para que Laravel lo sirva como vista
if (Test-Path "$buildWebDir\index.html") {
    Copy-Item -Path "$buildWebDir\index.html" -Destination $bladeViewPath -Force
    Write-Host "Se actualizo app.blade.php con el nuevo index.html." -ForegroundColor Green
}

# 6. Borrar index.html del public de Laravel para evitar conflictos con las rutas amigables de Laravel
$publicIndexHtml = Join-Path $publicDir "index.html"
if (Test-Path $publicIndexHtml) {
    Remove-Item -Path $publicIndexHtml -Force
}

Write-Host "Proceso terminado con exito! Listo para hacer git add, commit y push en produccion." -ForegroundColor Green


# powershell -ExecutionPolicy Bypass -File .\compilar_web.ps1
# toqxih-kAfhyf-xagha6