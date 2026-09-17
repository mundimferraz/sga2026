# ==============================================================================
#  FilaSystem — Parar todos os processos
#  Execute com: powershell -ExecutionPolicy Bypass -File stop.ps1
# ==============================================================================

$Root = $PSScriptRoot

function Stop-ByPidFile($pidFile, $name) {
    if (Test-Path $pidFile) {
        $pid = Get-Content $pidFile -Raw
        $pid = $pid.Trim()
        try {
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] $name (PID $pid) encerrado" -ForegroundColor Green
        } catch {
            Write-Host "  [INFO] $name ja estava parado ou PID invalido" -ForegroundColor DarkGray
        }
        Remove-Item $pidFile -Force
    } else {
        Write-Host "  [INFO] Nenhum PID salvo para $name" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "==> Encerrando FilaSystem..." -ForegroundColor Cyan

Stop-ByPidFile "$Root\.backend.pid"  "Backend"
Stop-ByPidFile "$Root\.frontend.pid" "Frontend"

# Mata qualquer node na porta 3001 e npm na porta 3000 (fallback)
$ports = @(3000, 3001)
foreach ($port in $ports) {
    $connections = netstat -ano 2>$null | Select-String ":$port\s"
    foreach ($line in $connections) {
        if ($line -match '\s+(\d+)\s*$') {
            $pidNum = $matches[1]
            if ($pidNum -ne "0") {
                try { Stop-Process -Id $pidNum -Force -ErrorAction SilentlyContinue } catch {}
            }
        }
    }
}

Write-Host ""
Write-Host "  Sistema encerrado." -ForegroundColor Green
Write-Host ""
