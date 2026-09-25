<#
  Claude Desktop 简体中文语言包 —— 一键应用脚本（Windows / MSIX 版）

  用法：
    1. 完全退出 Claude Desktop
    2. 右键「以管理员身份运行」PowerShell，执行：
         powershell -ExecutionPolicy Bypass -File apply.ps1
       或直接右键本文件 → 使用 PowerShell 运行（会提示提权）
    3. 打开 Claude Desktop → 左下角头像 → Language → 选择 Français

  原理：Claude Desktop 在语言为 en-US 时不读取语言文件（直接使用内置英文），
        只有非英语语言才会读取 /i18n/<locale>.json。因此本脚本把中文写入
        英文与法文两个语言文件；再把界面语言切到「法语」，即可显示中文。
#>
#requires -RunAsAdministrator

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)

Write-Host "`n=== Claude Desktop 简体中文语言包 ===`n" -ForegroundColor Cyan

# ---------- 1. 定位安装目录 ----------
$pkg = Get-ChildItem "$env:ProgramFiles\WindowsApps" -Directory -Filter 'Claude_*' -ErrorAction SilentlyContinue |
       Where-Object { Test-Path (Join-Path $_.FullName 'app\resources\ion-dist\i18n') } |
       Sort-Object Name -Descending | Select-Object -First 1
if (-not $pkg) { throw '找不到 Claude Desktop 安装目录，请确认已安装 MSIX 版。' }
$i18n = Join-Path $pkg.FullName 'app\resources\ion-dist\i18n'
Write-Host "安装位置: $($pkg.FullName)`n" -ForegroundColor Green

# ---------- 2. 读取词表 ----------
$here   = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$dict   = [IO.File]::ReadAllText((Join-Path $here 'zh-CN.json'),         [Text.Encoding]::UTF8) | ConvertFrom-Json -AsHashtable
$dictDy = [IO.File]::ReadAllText((Join-Path $here 'dynamic-zh-CN.json'), [Text.Encoding]::UTF8) | ConvertFrom-Json -AsHashtable
Write-Host "词表载入: 主词表 $($dict.Count) 条 / 动态词表 $($dictDy.Count) 条`n" -ForegroundColor Green

# ---------- 3. 工具函数 ----------
function Ensure-Writable([string]$p) {
    # WindowsApps 内的文件归 TrustedInstaller 所有，普通管理员也需要先接管
    try { $fs = [IO.File]::Open($p, 'Open', 'ReadWrite'); $fs.Close(); return } catch {}
    takeown.exe /F "$p" /A | Out-Null
    icacls.exe  "$p" /grant "*S-1-5-32-544:F" | Out-Null
    icacls.exe  "$p" /grant "${env:USERNAME}:(F)" | Out-Null
}

function Apply-Locale([string]$name, [hashtable]$patch) {
    $target = Join-Path $i18n $name
    if (-not (Test-Path $target)) { Write-Host "  跳过（文件不存在）: $name" -ForegroundColor DarkGray; return }
    # 注意：这些文件带 EFS 加密属性，Copy-Item 会失败，必须用字节级读写
    $j = [IO.File]::ReadAllText($target, [Text.Encoding]::UTF8) | ConvertFrom-Json -AsHashtable
    $hit = 0
    foreach ($k in $patch.Keys) { if ($j.ContainsKey($k)) { $j[$k] = $patch[$k]; $hit++ } }
    Ensure-Writable $target
    [IO.File]::WriteAllText($target, ($j | ConvertTo-Json -Depth 50 -Compress), $enc)
    Write-Host ("  {0,-34} 已写入 {1,6} / {2,6} 条" -f $name, $hit, $j.Count) -ForegroundColor Green
}

# ---------- 4. 写入主语言文件（英文 + 法文）----------
Write-Host "写入语言文件：" -ForegroundColor Yellow
Apply-Locale 'en-US.json' $dict
Apply-Locale 'fr-FR.json' $dict

$ov = Join-Path $i18n 'fr-FR.overrides.json'
if (Test-Path $ov) {
    Ensure-Writable $ov
    [IO.File]::WriteAllText($ov, '{}', $enc)
    Write-Host ("  {0,-34} 已清空（否则会覆盖译文）" -f 'fr-FR.overrides.json') -ForegroundColor Green
}

# ---------- 5. 写入动态词表 ----------
foreach ($n in @('dynamic\en-US.json', 'dynamic\fr-FR.json')) {
    $t = Join-Path $i18n $n
    if (-not (Test-Path $t)) { continue }
    $j = [IO.File]::ReadAllText($t, [Text.Encoding]::UTF8) | ConvertFrom-Json -AsHashtable
    $hit = 0
    foreach ($k in $dictDy.Keys) { if ($j.ContainsKey($k)) { $j[$k] = $dictDy[$k]; $hit++ } }
    Ensure-Writable $t
    [IO.File]::WriteAllText($t, ($j | ConvertTo-Json -Depth 20 -Compress), $enc)
    Write-Host ("  {0,-34} 已写入 {1,6} 条" -f $n, $hit) -ForegroundColor Green
}

# ---------- 6. 收尾提示 ----------
Write-Host "`n完成！接下来两步：" -ForegroundColor Cyan
Write-Host "  1) 打开 Claude Desktop → 左下角头像 → Language → 选择 " -NoNewline
Write-Host "Français" -ForegroundColor Yellow
Write-Host "  2) 界面即显示中文（这是关键：英文是内置默认，不会读取语言文件）"
Write-Host "`n  提示：应用更新后语言文件会被覆盖，中文失效时重新运行本脚本即可。`n"
