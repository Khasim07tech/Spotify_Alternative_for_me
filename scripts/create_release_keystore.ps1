param(
  [string]$Alias = "kx-wave-upload",
  [string]$StorePassword = "KXWaveRelease2026!",
  [string]$KeyPassword = "KXWaveRelease2026!"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $projectRoot "android"
$appDir = Join-Path $androidDir "app"
$keyStorePath = Join-Path $appDir "kx-wave-upload-keystore.jks"
$keyPropertiesPath = Join-Path $androidDir "key.properties"
$localJdk = Get-ChildItem (Join-Path $projectRoot ".tooling") -Directory -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -like "jdk-*" } |
  Select-Object -First 1

if ($localJdk) {
  $env:JAVA_HOME = $localJdk.FullName
  $env:Path = "$($env:JAVA_HOME)\bin;$env:Path"
}

if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
  throw "keytool was not found. Install a JDK or keep the bundled .tooling JDK."
}

if (-not (Test-Path $keyStorePath)) {
  & keytool -genkeypair `
    -v `
    -keystore $keyStorePath `
    -storetype JKS `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias $Alias `
    -storepass $StorePassword `
    -keypass $KeyPassword `
    -dname "CN=KX Wave, OU=Mobile, O=KX Technologies, L=Hyderabad, ST=Telangana, C=IN"
}

@"
storePassword=$StorePassword
keyPassword=$KeyPassword
keyAlias=$Alias
storeFile=app/kx-wave-upload-keystore.jks
"@ | Set-Content -Path $keyPropertiesPath -Encoding ascii

Write-Host "Release signing configured at android/key.properties"
Write-Host "Keystore created at android/app/kx-wave-upload-keystore.jks"
