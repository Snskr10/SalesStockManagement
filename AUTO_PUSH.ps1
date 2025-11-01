# Auto-Push Script - Run this after creating the repository on GitHub
# This will push all your committed files automatically

Write-Host "🚀 Auto-Push to GitHub" -ForegroundColor Cyan
Write-Host ""

# Check if repository exists
Write-Host "Checking repository..." -ForegroundColor Yellow
$repoCheck = git ls-remote https://github.com/Snskr10/SalesStockManagement.git 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Repository found! Pushing code..." -ForegroundColor Green
    Write-Host ""
    
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 SUCCESS! Your code has been pushed to GitHub!" -ForegroundColor Green
        Write-Host "📍 Repository: https://github.com/Snskr10/SalesStockManagement" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "❌ Push failed. Check authentication or repository status." -ForegroundColor Red
    }
} else {
    Write-Host "❌ Repository not found. Please create it first on GitHub." -ForegroundColor Red
    Write-Host ""
    Write-Host "Go to: https://github.com/new?name=SalesStockManagement" -ForegroundColor Yellow
    Write-Host "Then run this script again." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"

