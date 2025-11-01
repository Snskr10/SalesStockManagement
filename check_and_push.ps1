# Check and Push Script
Write-Host ""
Write-Host "Checking if repository exists..." -ForegroundColor Yellow

$result = git ls-remote https://github.com/Snskr10/SalesStockManagement.git 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Repository found! Pushing code..." -ForegroundColor Green
    Write-Host ""
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "SUCCESS! Code pushed to GitHub!" -ForegroundColor Green
        Write-Host "Repository: https://github.com/Snskr10/SalesStockManagement" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "Push failed. Check authentication." -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "Repository not found. Please create it first." -ForegroundColor Red
    Write-Host "Go to: https://github.com/new" -ForegroundColor Yellow
    Write-Host "Name: SalesStockManagement" -ForegroundColor Yellow
    Write-Host "Then run this script again." -ForegroundColor Yellow
}

