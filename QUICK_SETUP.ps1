# Quick GitHub Repository Setup Script
# Run this script if repository creation fails

Write-Host "🚀 Setting up GitHub Repository..." -ForegroundColor Cyan
Write-Host ""

# Check if repository exists by trying to fetch
Write-Host "Checking if repository exists..." -ForegroundColor Yellow
$checkRepo = git ls-remote https://github.com/Snskr10/SalesStockManagement.git 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Repository doesn't exist yet." -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Quick Steps to Create Repository:" -ForegroundColor Cyan
    Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
    Write-Host "2. Repository name: SalesStockManagement" -ForegroundColor White
    Write-Host "3. Description: Complete billing and inventory management system" -ForegroundColor White
    Write-Host "4. Choose Public or Private" -ForegroundColor White
    Write-Host "5. DO NOT check any boxes (README, .gitignore, license)" -ForegroundColor Yellow
    Write-Host "6. Click 'Create repository'" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run: git push -u origin main" -ForegroundColor Green
    Write-Host ""
    Write-Host "Or press Enter to open GitHub in your browser..." -ForegroundColor Cyan
    Read-Host
    Start-Process "https://github.com/new"
} else {
    Write-Host "✅ Repository exists! Pushing code..." -ForegroundColor Green
    git push -u origin main
}

