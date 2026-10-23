# 把 plugin/ 里的打过补丁的 dsh-pet 文件装回 DSH profile。
# 用法：
#   .\install.ps1
#   .\install.ps1 -ProfileDir "C:\Users\you\.dsh\profiles\desktop"
#   .\install.ps1 -SkipConfig      # 只覆盖 lib/*.js，不动 assets/config.jsonc
param(
    [string]$ProfileDir = (Join-Path $env:USERPROFILE ".dsh\profiles\desktop"),
    [switch]$SkipConfig
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$target = Join-Path $ProfileDir "node_modules\dsh-pet"

if (-not (Test-Path $target)) {
    throw "找不到 dsh-pet：$target（先用 DSH 插件市场安装 dsh-pet@0.3.8）"
}

Copy-Item (Join-Path $root "plugin\lib\index.js")  (Join-Path $target "lib\index.js")  -Force
Copy-Item (Join-Path $root "plugin\lib\client.js") (Join-Path $target "lib\client.js") -Force
Write-Host "已覆盖 lib/index.js, lib/client.js"

if (-not $SkipConfig) {
    Copy-Item (Join-Path $root "plugin\assets\config.jsonc") (Join-Path $target "assets\config.jsonc") -Force
    Write-Host "已覆盖 assets/config.jsonc（内置默认值；用户配置 main-config.jsonc 不受影响）"
}

Write-Host ""
Write-Host "装好了。重启 DSH 后生效；配置项在 $env:USERPROFILE\.dsh\dsh-pet\main-config.jsonc："
Write-Host "  hearthstoneMode = true/false   手动开关"
Write-Host "  hearthstoneAuto = true/false   随炉石游戏进程自动切换"
