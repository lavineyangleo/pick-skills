# pick-skills / lavineleo — allowlisted GitHub source archive
[CmdletBinding()]
param([string]$OutputDirectory)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectRoot = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $projectRoot 'releases' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
$package = Get-Content -LiteralPath (Join-Path $projectRoot 'package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($package.name -ne 'pick-skills' -or $package.version -notmatch '^\d+\.\d+\.\d+$') { throw '项目名称或版本无效' }
$files = @(
  'README.md','SKILL.md','LICENSE','CHANGELOG.md','.gitignore',
  'package.json','package-lock.json',
  'assets/logo-捡垃圾-v1.png',
  'infra/browser-浏览器-v1.cjs',
  'scripts/xianyu.js','scripts/chrome-启动-v1.cjs','scripts/doctor-环境诊断-v1.cjs',
  'scripts/setup-Windows安装-v1.ps1','scripts/package-GitHub打包-v1.ps1',
  'docs/INSTALL-WINDOWS.md','.github/workflows/windows.yml'
)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$archivePath = Join-Path $OutputDirectory "pick-skills-v$($package.version)-github.zip"
if (Test-Path -LiteralPath $archivePath) { throw "文件已存在，请指定新的 OutputDirectory：$archivePath" }
$stage = Join-Path $OutputDirectory ('stage-' + [Guid]::NewGuid().ToString('N'))
$sourceRoot = Join-Path $stage 'pick-skills'
New-Item -ItemType Directory -Path $sourceRoot -Force | Out-Null
foreach ($relative in $files) {
  $source = Join-Path $projectRoot $relative
  if ($relative -eq '.github/workflows/windows.yml' -and -not (Test-Path -LiteralPath $source)) { $source = Join-Path $projectRoot 'docs/windows-workflow.yml' }
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "缺少发布文件：$relative" }
  $destination = Join-Path $sourceRoot $relative
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
  Copy-Item -LiteralPath $source -Destination $destination
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($sourceRoot, $archivePath, [IO.Compression.CompressionLevel]::Optimal, $true)
$zip = [IO.Compression.ZipFile]::OpenRead($archivePath)
try {
  $expected = @($files | ForEach-Object { 'pick-skills/' + $_.Replace('\','/') })
  $actual = @($zip.Entries | ForEach-Object { $_.FullName.Replace('\','/') })
  $difference = Compare-Object $expected $actual
  if ($difference) { throw ('归档文件清单不符：' + ($difference | Out-String)) }
} finally { $zip.Dispose() }
$hash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText($archivePath + '.sha256', "$hash  $([IO.Path]::GetFileName($archivePath))`n", [Text.Encoding]::ASCII)
Write-Host "已生成：$archivePath"
Write-Host "SHA256：$hash"
Write-Host "源码目录：$sourceRoot"
