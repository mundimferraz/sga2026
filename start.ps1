# ==============================================================================
#  FilaSystem — Inicialização Rápida (após setup.ps1 já ter sido executado)
#  Execute com: powershell -ExecutionPolicy Bypass -File start.ps1
# ==============================================================================

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

function Write-Step($msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

# --------------------------------------------------------------------------
# Verifica se o build existe
# --------------------------------------------------------------------------
if (-not (Test-Path "$Root\backend\dist\main.js")) {
    Write-Host ""
    Write-Host "  [AVISO] Build do backend nao encontrado." -ForegroundColor Yellow
    Write-Host "  Execute primeiro: powershell -ExecutionPolicy Bypass -File setup.ps1" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "$Root\frontend\.next")) {
    Write-Host ""
    Write-Host "  [AVISO] Build do frontend nao encontrado." -ForegroundColor Yellow
    Write-Host "  Execute primeiro: powershell -ExecutionPolicy Bypass -File setup.ps1" -ForegroundColor Yellow
    exit 1
}

# --------------------------------------------------------------------------
# Inicia o backend em segundo plano
# --------------------------------------------------------------------------
Write-Step "Iniciando backend (porta 3001)..."

$backendJob = Start-Process -FilePath "node" `
    -ArgumentList "dist\main.js" `
    -WorkingDirectory "$Root\backend" `
    -PassThru `
    -NoNewWindow `
    -RedirectStandardOutput "$Root\backend\backend.log" `
    -RedirectStandardError  "$Root\backend\backend-error.log"

Start-Sleep -Seconds 2
Write-Host "  Backend PID: $($backendJob.Id)" -ForegroundColor Green
Write-Host "  Log: $Root\backend\backend.log" -ForegroundColor DarkGray

# --------------------------------------------------------------------------
# Inicia o frontend em segundo plano
# --------------------------------------------------------------------------
Write-Step "Iniciando frontend (porta 3000)..."

$frontendJob = Start-Process -FilePath "npm" `
    -ArgumentList "start" `
    -WorkingDirectory "$Root\frontend" `
    -PassThru `
    -NoNewWindow `
    -RedirectStandardOutput "$Root\frontend\frontend.log" `
    -RedirectStandardError  "$Root\frontend\frontend-error.log"

Start-Sleep -Seconds 3
Write-Host "  Frontend PID: $($frontendJob.Id)" -ForegroundColor Green
Write-Host "  Log: $Root\frontend\frontend.log" -ForegroundColor DarkGray

# --------------------------------------------------------------------------
# Resumo
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Sistema iniciado!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Sistema (navegador) : http://localhost:3000" -ForegroundColor Cyan
Write-Host "  API (backend)       : http://localhost:3001/api" -ForegroundColor Cyan
Write-Host ""
Write-Host "  PIDs em execucao:" -ForegroundColor White
Write-Host "    Backend  PID: $($backendJob.Id)" -ForegroundColor DarkGray
Write-Host "    Frontend PID: $($frontendJob.Id)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Para parar o sistema execute stop.ps1" -ForegroundColor Yellow
Write-Host ""

# Salva os PIDs para o stop.ps1
"$($backendJob.Id)" | Out-File "$Root\.backend.pid"
"$($frontendJob.Id)" | Out-File "$Root\.frontend.pid"

# Abre o navegador automaticamente
Start-Sleep -Seconds 5
Start-Process "http://localhost:3000"
