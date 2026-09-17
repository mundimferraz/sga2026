# ==============================================================================
#  FilaSystem - Setup e Build Completo (Windows PowerShell)
#  Execute com: powershell -ExecutionPolicy Bypass -File setup.ps1
# ==============================================================================

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

function Write-Step($msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

function Write-OK($msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-Fail($msg) {
    Write-Host "  [ERRO] $msg" -ForegroundColor Red
    exit 1
}

# --------------------------------------------------------------------------
# 1. Verifica dependencias
# --------------------------------------------------------------------------
Write-Step "Verificando dependencias..."

try { $nodeVer = node --version 2>&1; Write-OK "Node.js $nodeVer" }
catch { Write-Fail "Node.js nao encontrado. Instale em https://nodejs.org (versao LTS)" }

try { $npmVer = npm --version 2>&1; Write-OK "npm $npmVer" }
catch { Write-Fail "npm nao encontrado." }

# --------------------------------------------------------------------------
# 2. Configura .env do backend
# --------------------------------------------------------------------------
Write-Step "Configurando arquivo .env do backend..."

$envPath    = "$Root\backend\.env"
$envExample = "$Root\backend\.env.example"

if (-not (Test-Path $envPath)) {
    Copy-Item $envExample $envPath
    Write-OK ".env criado a partir do .env.example"
} else {
    Write-OK ".env ja existe - mantendo configuracao atual"
}

# --------------------------------------------------------------------------
# 3. Instala dependencias do backend
# --------------------------------------------------------------------------
Write-Step "Instalando dependencias do backend..."

Push-Location "$Root\backend"
npm install
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "npm install falhou no backend" }
Write-OK "Dependencias do backend instaladas"
Pop-Location

# --------------------------------------------------------------------------
# 4. Gera Prisma Client
# --------------------------------------------------------------------------
Write-Step "Gerando Prisma Client..."

Push-Location "$Root\backend"
npx prisma generate
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "prisma generate falhou" }
Write-OK "Prisma Client gerado"
Pop-Location

# --------------------------------------------------------------------------
# 5. Build do backend (NestJS -> dist/)
# --------------------------------------------------------------------------
Write-Step "Compilando backend (NestJS)..."

Push-Location "$Root\backend"
npm run build
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "Build do backend falhou" }
Write-OK "Backend compilado em backend/dist/"
Pop-Location

# --------------------------------------------------------------------------
# 6. Instala dependencias do frontend
# --------------------------------------------------------------------------
Write-Step "Instalando dependencias do frontend..."

Push-Location "$Root\frontend"
npm install
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "npm install falhou no frontend" }
Write-OK "Dependencias do frontend instaladas"
Pop-Location

# --------------------------------------------------------------------------
# 7. Build do frontend (Next.js -> .next/)
# --------------------------------------------------------------------------
Write-Step "Compilando frontend (Next.js)..."

Push-Location "$Root\frontend"
npm run build
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "Build do frontend falhou" }
Write-OK "Frontend compilado em frontend/.next/"
Pop-Location

# --------------------------------------------------------------------------
# 8. Migration e seed do banco (opcional - requer PostgreSQL rodando)
# --------------------------------------------------------------------------
Write-Step "Banco de dados..."

Write-Host ""
Write-Host "  O sistema precisa do PostgreSQL rodando para aplicar a migration." -ForegroundColor Yellow
Write-Host "  Verifique se o PostgreSQL esta ativo e que o .env esta correto." -ForegroundColor Yellow
Write-Host ""
$resp = Read-Host "  Deseja aplicar a migration e o seed agora? (s/N)"

if ($resp -match '^[sS]$') {
    Push-Location "$Root\backend"

    Write-Step "Aplicando migration..."
    npx prisma migrate deploy
    if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "Migration falhou. Verifique o PostgreSQL e o DATABASE_URL no .env" }
    Write-OK "Migration aplicada"

    Write-Step "Populando banco com dados de teste (seed)..."
    npx ts-node prisma/seed.ts
    if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Fail "Seed falhou" }
    Write-OK "Seed concluido"

    Pop-Location
} else {
    Write-Host "  Pulando migration/seed. Execute manualmente quando o banco estiver pronto:" -ForegroundColor DarkGray
    Write-Host "    cd backend" -ForegroundColor DarkGray
    Write-Host "    npx prisma migrate deploy" -ForegroundColor DarkGray
    Write-Host "    npx ts-node prisma/seed.ts" -ForegroundColor DarkGray
}

# --------------------------------------------------------------------------
# Resumo final
# --------------------------------------------------------------------------
Write-Host ""
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Build concluido com sucesso!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Para iniciar o sistema, execute:" -ForegroundColor White
Write-Host "    powershell -ExecutionPolicy Bypass -File start.ps1" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Ou manualmente:" -ForegroundColor White
Write-Host "    Terminal 1 (backend) : cd backend  ; node dist/main" -ForegroundColor DarkGray
Write-Host "    Terminal 2 (frontend): cd frontend ; npm start" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Acesse o sistema em: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
