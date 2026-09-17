# ==============================================================================
#  FilaSystem — Build para Distribuicao Local
#  Gera a pasta dist/ pronta para copiar e executar em qualquer maquina Windows
#  Execute com: powershell -ExecutionPolicy Bypass -File build.ps1
# ==============================================================================

$ErrorActionPreference = "Stop"
$Root      = $PSScriptRoot
$DistDir   = "$Root\dist"
$BuildDate = Get-Date -Format "yyyyMMdd_HHmmss"

function Write-Step($msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

function Write-OK($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "  [ERRO] $msg" -ForegroundColor Red; exit 1 }

# --------------------------------------------------------------------------
# 0. Verifica Node/npm
# --------------------------------------------------------------------------
Write-Step "Verificando ambiente..."

try { $nv = node --version 2>&1; Write-OK "Node.js $nv" }
catch { Write-Fail "Node.js nao encontrado. Instale em https://nodejs.org" }

try { $npmv = npm --version 2>&1; Write-OK "npm $npmv" }
catch { Write-Fail "npm nao encontrado" }

# --------------------------------------------------------------------------
# 1. Limpa dist anterior
# --------------------------------------------------------------------------
Write-Step "Limpando dist/ anterior..."

if (Test-Path $DistDir) {
    Remove-Item $DistDir -Recurse -Force
    Write-OK "dist/ removido"
}
New-Item -ItemType Directory -Path $DistDir | Out-Null
New-Item -ItemType Directory -Path "$DistDir\backend"  | Out-Null
New-Item -ItemType Directory -Path "$DistDir\frontend" | Out-Null

# --------------------------------------------------------------------------
# 2. BUILD — Backend
# --------------------------------------------------------------------------
Write-Step "Instalando dependencias do backend..."
Push-Location "$Root\backend"
npm install
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "npm install (backend) falhou" }
Write-OK "Dependencias instaladas"
Pop-Location

Write-Step "Gerando Prisma Client..."
Push-Location "$Root\backend"
npx prisma generate
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "prisma generate falhou" }
Write-OK "Prisma Client gerado"
Pop-Location

Write-Step "Compilando backend (NestJS)..."
Push-Location "$Root\backend"
npm run build
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "nest build falhou" }
Write-OK "Backend compilado => backend/dist/"
Pop-Location

# --------------------------------------------------------------------------
# 3. BUILD — Frontend
# --------------------------------------------------------------------------
Write-Step "Instalando dependencias do frontend..."
Push-Location "$Root\frontend"
npm install
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "npm install (frontend) falhou" }
Write-OK "Dependencias instaladas"
Pop-Location

Write-Step "Compilando frontend (Next.js)..."
Push-Location "$Root\frontend"
npm run build
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "next build falhou" }
Write-OK "Frontend compilado => frontend/.next/"
Pop-Location

# --------------------------------------------------------------------------
# 4. Copia artefatos para dist/
# --------------------------------------------------------------------------
Write-Step "Copiando artefatos para dist/..."

# --- Backend: dist compilado + node_modules de producao + prisma ---
Write-Host "  Copiando backend/dist..." -ForegroundColor DarkGray
Copy-Item "$Root\backend\dist"          "$DistDir\backend\dist"          -Recurse
Copy-Item "$Root\backend\prisma"        "$DistDir\backend\prisma"        -Recurse
Copy-Item "$Root\backend\package.json"  "$DistDir\backend\package.json"
Copy-Item "$Root\backend\tsconfig.json" "$DistDir\backend\tsconfig.json"

# .env: copia o .env.example como template (usuario configura depois)
Copy-Item "$Root\backend\.env.example"  "$DistDir\backend\.env.example"

# Instala apenas dependencias de producao no dist/
Write-Host "  Instalando node_modules de producao no dist/backend..." -ForegroundColor DarkGray
Push-Location "$DistDir\backend"
npm install --omit=dev
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "npm install --omit=dev (backend dist) falhou" }
# Regenera o Prisma Client dentro do dist
npx prisma generate
Pop-Location
Write-OK "Backend pronto em dist/backend/"

# --- Frontend: .next + public + package.json ---
Write-Host "  Copiando frontend/.next..." -ForegroundColor DarkGray
Copy-Item "$Root\frontend\.next"        "$DistDir\frontend\.next"        -Recurse
Copy-Item "$Root\frontend\public"       "$DistDir\frontend\public"       -Recurse -ErrorAction SilentlyContinue
Copy-Item "$Root\frontend\package.json" "$DistDir\frontend\package.json"
Copy-Item "$Root\frontend\next.config.js" "$DistDir\frontend\next.config.js"

# Instala apenas dependencias de producao no dist/frontend
Write-Host "  Instalando node_modules de producao no dist/frontend..." -ForegroundColor DarkGray
Push-Location "$DistDir\frontend"
npm install --omit=dev
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "npm install --omit=dev (frontend dist) falhou" }
Pop-Location
Write-OK "Frontend pronto em dist/frontend/"

# --------------------------------------------------------------------------
# 5. Copia scripts de execucao para dist/
# --------------------------------------------------------------------------
Write-Step "Copiando scripts de execucao..."

Copy-Item "$Root\start.ps1"     "$DistDir\start.ps1"
Copy-Item "$Root\stop.ps1"      "$DistDir\stop.ps1"
Copy-Item "$Root\README.md"     "$DistDir\README.md"  -ErrorAction SilentlyContinue

# Cria um .env padrao dentro do dist/backend se nao existir
if (-not (Test-Path "$DistDir\backend\.env")) {
    Copy-Item "$DistDir\backend\.env.example" "$DistDir\backend\.env"
    Write-OK ".env criado com configuracoes padrao"
}

# --------------------------------------------------------------------------
# 6. Gera ZIP para download
# --------------------------------------------------------------------------
Write-Step "Gerando arquivo ZIP..."

$ZipName = "FilaSystem_build_$BuildDate.zip"
$ZipPath = "$Root\$ZipName"

Compress-Archive -Path "$DistDir\*" -DestinationPath $ZipPath -Force
Write-OK "ZIP gerado: $ZipName"

# --------------------------------------------------------------------------
# Resumo final
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  BUILD CONCLUIDO!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Pasta de distribuicao : $DistDir"     -ForegroundColor White
Write-Host "  Arquivo ZIP           : $ZipPath"     -ForegroundColor Yellow
Write-Host ""
Write-Host "  Para usar em outra maquina:" -ForegroundColor White
Write-Host "    1. Copie o ZIP para a maquina destino"                             -ForegroundColor DarkGray
Write-Host "    2. Extraia o ZIP"                                                   -ForegroundColor DarkGray
Write-Host "    3. Edite o arquivo backend\.env com as credenciais do PostgreSQL"   -ForegroundColor DarkGray
Write-Host "    4. Execute: powershell -ExecutionPolicy Bypass -File start.ps1"     -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Na primeira execucao na maquina destino, aplique a migration:" -ForegroundColor White
Write-Host "    cd backend"                                                   -ForegroundColor DarkGray
Write-Host "    npx prisma migrate deploy"                                    -ForegroundColor DarkGray
Write-Host "    npx ts-node prisma\seed.ts"                                   -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Acesse em: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
