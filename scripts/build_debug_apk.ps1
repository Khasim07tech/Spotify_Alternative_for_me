param(
  [switch]$SkipChecks
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$shortProjectRoot = cmd /c "for %A in (""$projectRoot"") do @echo %~sA"
$executionRoot = if ($shortProjectRoot) { $shortProjectRoot } else { $projectRoot }
$localFlutter = Join-Path $executionRoot ".tooling/flutter/bin/flutter.bat"
$localSdk = Join-Path $executionRoot ".tooling/android-sdk"
$localJdk = Get-ChildItem (Join-Path $executionRoot ".tooling") -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like "jdk-*" } |
  Select-Object -First 1

if (Test-Path $localFlutter) {
  $flutter = $localFlutter
} else {
  $flutter = "flutter"
}

if ($localJdk) {
  $env:JAVA_HOME = $localJdk.FullName
  $env:Path = "$($env:JAVA_HOME)\bin;$env:Path"
}

if (Test-Path $localSdk) {
  $env:ANDROID_HOME = $localSdk
  $env:ANDROID_SDK_ROOT = $localSdk
}

Push-Location $executionRoot
try {
  & $flutter pub get
  if (-not $SkipChecks) {
    & $flutter analyze
    & $flutter test
  }
  & $flutter build apk --debug

  $apkPath = Join-Path $executionRoot "build/app/outputs/flutter-apk/app-debug.apk"
  $distDir = Join-Path $projectRoot "dist"
  New-Item -ItemType Directory -Force -Path $distDir | Out-Null
  Copy-Item -Force $apkPath (Join-Path $distDir "kx-wave-v0.7-ai-recommendations-debug.apk")
  Write-Host "APK generated: $distDir/kx-wave-v0.7-ai-recommendations-debug.apk"
} finally {
  Pop-Location
}
