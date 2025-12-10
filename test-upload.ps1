# 简单测试题目图片上传接口

Write-Host "测试题目图片上传接口" -ForegroundColor Cyan
Write-Host "============================================`n"

# 查找测试图片
$testImage = $null
$avatarDir = ".\backend\uploads\avatars"

if (Test-Path $avatarDir) {
    $images = Get-ChildItem -Path $avatarDir -Recurse -Filter "*.jpg" | Select-Object -First 1
    if ($images) {
        $testImage = $images.FullName
        Write-Host "找到测试图片: $($images.Name)" -ForegroundColor Green
    }
}

if (-not $testImage) {
    Write-Host "未找到测试图片！请先上传头像或放置test-image.jpg在根目录" -ForegroundColor Red
    exit 1
}

# 显示文件信息
$fileInfo = Get-Item $testImage
Write-Host "文件大小: $([math]::Round($fileInfo.Length / 1KB, 2)) KB`n" -ForegroundColor Yellow

# 上传文件
Write-Host "正在上传到 http://localhost:8080/api/file/upload/question-image ..." -ForegroundColor Cyan

$url = "http://localhost:8080/api/file/upload/question-image"
$form = @{
    file = Get-Item -Path $testImage
}

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Form $form
    
    Write-Host "`n上传成功！`n" -ForegroundColor Green
    Write-Host "响应数据:" -ForegroundColor Cyan
    $response | ConvertTo-Json
    
    if ($response.code -eq 200) {
        $imageUrl = $response.data.url
        Write-Host "`n图片URL: $imageUrl" -ForegroundColor Green
        Write-Host "完整访问地址: http://localhost:8080/api$imageUrl" -ForegroundColor Green
        
        # 测试访问
        Write-Host "`n正在测试图片访问..." -ForegroundColor Cyan
        $accessUrl = "http://localhost:8080/api$imageUrl"
        $testAccess = Invoke-WebRequest -Uri $accessUrl -Method Get
        
        if ($testAccess.StatusCode -eq 200) {
            Write-Host "图片可以正常访问！" -ForegroundColor Green
            Write-Host "Content-Type: $($testAccess.Headers['Content-Type'])" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Host "`n上传失败！" -ForegroundColor Red
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n============================================" -ForegroundColor Cyan
