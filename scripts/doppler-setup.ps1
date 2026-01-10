$ErrorActionPreference = "Stop"

Write-Host "=== NCKH Doppler Setup ===" -ForegroundColor Cyan
Write-Host ""

$dopplerPath = Get-Command doppler -ErrorAction SilentlyContinue
if (-not $dopplerPath) {
    Write-Host "Error: Doppler CLI is not installed." -ForegroundColor Red
    Write-Host "Install options:"
    Write-Host "  1. Scoop: scoop install doppler"
    Write-Host "  2. Winget: winget install DopplerHQ.doppler"
    Write-Host "  3. Download: https://docs.doppler.com/docs/install-cli#windows"
    exit 1
}

try {
    doppler me | Out-Null
} catch {
    Write-Host "Error: Not logged in to Doppler." -ForegroundColor Red
    Write-Host "Run: doppler login"
    exit 1
}

$projectName = "nckh"

Write-Host "Setting up Doppler project: $projectName" -ForegroundColor Green
Write-Host ""

try {
    doppler projects create $projectName --description "NCKH monorepo secrets" 2>$null
} catch {
}

try {
    doppler setup --project $projectName --config dev --no-interactive 2>$null
} catch {
    Write-Host "  - Run 'doppler setup' manually if needed" -ForegroundColor Yellow
}

Write-Host "  ✓ Project $projectName ready" -ForegroundColor Green

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Add secrets via Doppler dashboard: https://dashboard.doppler.com"
Write-Host "2. Or use CLI: doppler secrets set KEY=value -p $projectName -c dev"
Write-Host ""
Write-Host "Required secrets:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  - AUTH_DATABASE_URL (PostgreSQL, schema: public)"
Write-Host "  - ACADEMIC_DATABASE_URL (PostgreSQL, schema: academic)"
Write-Host "  - CERTIFICATION_DATABASE_URL (PostgreSQL, schema: certification)"
Write-Host "  - BETTER_AUTH_SECRET"
Write-Host ""
Write-Host "To run a service with Doppler:"
Write-Host "  bun run dev"
