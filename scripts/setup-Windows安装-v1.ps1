# pick-skills / lavineleo — Windows setup, requires PowerShell 5.1+
[CmdletBinding()]
param(
    [switch]$InstallPrerequisites,
    [switch]$CheckOnly,
    [string]$Registry = 'https://registry.npmjs.org',
    [string]$ProxyUrl
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectRoot = Split-Path -Parent $PSScriptRoot
function Refresh-ProcessPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
}
function Test-NodeVersion {
    if (-not (Get-Command node.exe -ErrorAction SilentlyContinue)) { return $false }
    $versionText = & node.exe -p 'process.versions.node'
    return ($LASTEXITCODE -eq 0 -and [version]$versionText -ge [version]'24.12.0')
}
function Find-Chrome {
    if ($env:XIANYU_CHROME_PATH -and (Test-Path -LiteralPath $env:XIANYU_CHROME_PATH -PathType Leaf)) { return $env:XIANYU_CHROME_PATH }
    foreach ($base in @($env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:LOCALAPPDATA)) {
        if ($base) {
            $candidate = Join-Path $base 'Google\Chrome\Application\chrome.exe'
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        }
    }
    return $null
}
function Install-WithWinget([string]$PackageId) {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw '未找到 winget。请通过 README 中的官方下载链接安装 Node.js 和 Chrome，再重试。'
    }
    & winget.exe install --id $PackageId --exact --source winget --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) { throw "winget 安装失败：$PackageId，退出码 $LASTEXITCODE" }
    Refresh-ProcessPath
}
try {
    if ($CheckOnly -and $InstallPrerequisites) { throw '-CheckOnly 不能与 -InstallPrerequisites 同时使用' }
    Push-Location $projectRoot
    try {
        $nodeReady = Test-NodeVersion
        if (-not $nodeReady -and $InstallPrerequisites) { Install-WithWinget 'OpenJS.NodeJS.LTS'; $nodeReady = Test-NodeVersion }
        if (-not $nodeReady) { throw '需要 Node.js 24.12+：https://nodejs.org/en/download 。安装后重新打开终端；或使用 -InstallPrerequisites 自动安装。' }
        $chrome = Find-Chrome
        if (-not $chrome -and $InstallPrerequisites) { Install-WithWinget 'Google.Chrome'; $chrome = Find-Chrome }
        if (-not $chrome) { throw '需要 Google Chrome：https://www.google.com/chrome/ 。也可设置 XIANYU_CHROME_PATH，或使用 -InstallPrerequisites。' }
        Write-Host "Chrome: $chrome"
        if (-not $CheckOnly) {
            if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) { throw '未找到 npm，请重新安装 Node.js 官方版本' }
            $npmArgs = @('ci', '--registry', $Registry, '--fetch-retries=1', '--fetch-timeout=30000')
            if ($ProxyUrl) { $npmArgs += @('--proxy', $ProxyUrl, '--https-proxy', $ProxyUrl) }
            & npm.cmd @npmArgs
            if ($LASTEXITCODE -ne 0) { throw 'npm ci 失败，请检查网络或代理。参见 docs/INSTALL-WINDOWS.md' }
        }
        & node.exe scripts/doctor-环境诊断-v1.cjs
        if ($LASTEXITCODE -ne 0) { throw '环境检查未通过，请根据以上提示处理' }
        Write-Host '环境就绪。执行 npm run browser:start，然后在 Chrome 中登录闲鱼。'
    } finally { Pop-Location }
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
