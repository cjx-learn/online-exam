# 测试题目图片上传接口

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "测试题目图片上传接口" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 获取 token（如果需要）
$token = ""
if (Test-Path ".\token.txt") {
    $token = Get-Content ".\token.txt" -Raw
}

# 检查是否有测试图片
$testImagePath = ".\test-image.jpg"

if (-not (Test-Path $testImagePath)) {
    Write-Host "未找到测试图片，正在创建测试图片..." -ForegroundColor Yellow
    
    # 创建一个简单的测试图片（使用系统自带的图片或创建纯色图片）
    # 尝试从头像上传目录复制一个已存在的图片
    $avatarDir = ".\backend\uploads\avatars"
    if (Test-Path $avatarDir) {
        $existingImages = Get-ChildItem -Path $avatarDir -Recurse -Filter "*.jpg" | Select-Object -First 1
        if ($existingImages) {
            Copy-Item $existingImages.FullName -Destination $testImagePath
            Write-Host "✓ 已复制测试图片: $($existingImages.Name)" -ForegroundColor Green
        }
    }
}

if (-not (Test-Path $testImagePath)) {
    Write-Host "✗ 未找到测试图片文件！" -ForegroundColor Red
    Write-Host "请在项目根目录放置一个名为 test-image.jpg 的图片文件" -ForegroundColor Yellow
    exit 1
}

Write-Host "测试图片: $testImagePath" -ForegroundColor Green
$fileInfo = Get-Item $testImagePath
Write-Host "文件大小: $([math]::Round($fileInfo.Length / 1024, 2)) KB" -ForegroundColor Green
Write-Host ""

# 测试 1: 上传题目图片（使用 Invoke-RestMethod）
Write-Host "【测试 1】上传题目图片到 /api/file/upload/question-image" -ForegroundColor Yellow
Write-Host "-----------------------------------------------" -ForegroundColor Gray

try {
    $url = "http://localhost:8080/api/file/upload/question-image"
    
    # 准备表单数据
    $form = @{
        file = Get-Item -Path $testImagePath
    }
    
    # 准备请求头
    $headers = @{}
    if ($token -ne "") {
        $headers["Authorization"] = $token
    }
    
    # 发送请求
    Write-Host "正在上传..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $url -Method Post -Form $form -Headers $headers
    
    Write-Host "✓ 上传成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "响应数据:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
    Write-Host ""
    
    if ($response.code -eq 200 -and $response.data.url) {
        $imageUrl = $response.data.url
        Write-Host "图片URL: $imageUrl" -ForegroundColor Green
        Write-Host "完整访问地址: http://localhost:8080/api$imageUrl" -ForegroundColor Green
        Write-Host ""
        
        # 测试图片访问
        Write-Host "【测试 2】访问上传的图片" -ForegroundColor Yellow
        Write-Host "-----------------------------------------------" -ForegroundColor Gray
        
        $imageAccessUrl = "http://localhost:8080/api$imageUrl"
        try {
            $imageResponse = Invoke-WebRequest -Uri $imageAccessUrl -Method Get
            if ($imageResponse.StatusCode -eq 200) {
                Write-Host "✓ 图片可以正常访问！" -ForegroundColor Green
                Write-Host "Content-Type: $($imageResponse.Headers['Content-Type'])" -ForegroundColor Cyan
                Write-Host "Content-Length: $($imageResponse.Headers['Content-Length']) bytes" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "✗ 图片访问失败: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "✗ 上传失败！" -ForegroundColor Red
    Write-Host "错误信息: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "详细错误: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "测试完成" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
