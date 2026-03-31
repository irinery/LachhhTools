param(
    [string]$MainClass = "com.flashinit.ReleaseInit",
    [string]$PackageTarget = "auto"
)

$ErrorActionPreference = "Stop"

$RootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$BinDir = Join-Path $RootDir "bin"
$BuildDir = Join-Path $RootDir "build"
$CertDir = Join-Path $BuildDir "certs"
$InstallersDir = Join-Path $RootDir "installers"
$DescriptorTemplate = Join-Path $RootDir "scripts/air-descriptor.template.xml"
$DescriptorPath = Join-Path $BinDir "TwitchGiveawayTool-app.xml"
$OutputSwf = Join-Path $BinDir "TwitchGiveawayTool.swf"
$WidgetOutput = Join-Path $BinDir "lachhhtools_widget.swf"
$WidgetSource = Join-Path $RootDir "platform/xSplitWidget/release/lachhhWidget.swf"
$CertPath = Join-Path $CertDir "dev-certificate.p12"

$AppId = if ($env:APP_ID) { $env:APP_ID } else { "com.lachhh.twitchgiveawaytool" }
$AppName = if ($env:APP_NAME) { $env:APP_NAME } else { "LachhhTools" }
$AppFilename = if ($env:APP_FILENAME) { $env:APP_FILENAME } else { "LachhhTools" }
$AppVersion = if ($env:APP_VERSION) { $env:APP_VERSION } else { "1.0.0" }
$AirNamespaceVersion = if ($env:AIR_NAMESPACE_VERSION) { $env:AIR_NAMESPACE_VERSION } else { "25.0" }
$CertPass = if ($env:CERT_PASS) { $env:CERT_PASS } else { "changeit" }

$AirHome = if ($env:AIR_HOME) { $env:AIR_HOME } elseif ($env:AIR_SDK_HOME) { $env:AIR_SDK_HOME } else { "" }
$LocalAir = Join-Path $RootDir "tools/air-sdk"
if (-not $AirHome -and (Test-Path $LocalAir)) {
    $AirHome = $LocalAir
}
if (-not $AirHome) {
    throw "Defina AIR_HOME (ou AIR_SDK_HOME) apontando para o AIR SDK."
}

$Compiler = Join-Path $AirHome "bin/amxmlc.bat"
if (-not (Test-Path $Compiler)) {
    $Compiler = Join-Path $AirHome "bin/mxmlc.bat"
}
if (-not (Test-Path $Compiler)) {
    throw "Nao encontrei amxmlc.bat/mxmlc.bat em $AirHome\bin."
}

$Adt = Join-Path $AirHome "bin/adt.bat"
if (-not (Test-Path $Adt)) {
    throw "Nao encontrei adt.bat em $AirHome\bin."
}

if ($PackageTarget -eq "auto") {
    if ($IsMacOS) { $PackageTarget = "bundle" } else { $PackageTarget = "native" }
}

New-Item -ItemType Directory -Force -Path $BinDir, $BuildDir, $CertDir, $InstallersDir | Out-Null

if (-not (Test-Path $WidgetOutput) -and (Test-Path $WidgetSource)) {
    Copy-Item $WidgetSource $WidgetOutput -Force
}
if (-not (Test-Path $WidgetOutput)) {
    throw "Arquivo do widget nao encontrado: $WidgetOutput (esperado tambem em $WidgetSource)"
}

$BinIcons = Join-Path $BinDir "icons"
New-Item -ItemType Directory -Force -Path $BinIcons | Out-Null
Copy-Item (Join-Path $RootDir "docs/Logos/Logos16.png") (Join-Path $BinIcons "Logos16.png") -Force
Copy-Item (Join-Path $RootDir "docs/Logos/Logos32_2.png") (Join-Path $BinIcons "Logos32_2.png") -Force
Copy-Item (Join-Path $RootDir "docs/Logos/Logos36_2.png") (Join-Path $BinIcons "Logos36_2.png") -Force
Copy-Item (Join-Path $RootDir "docs/Logos/Logos48_2.png") (Join-Path $BinIcons "Logos48_2.png") -Force
Copy-Item (Join-Path $RootDir "docs/Logos/Logo72x72.png") (Join-Path $BinIcons "Logo72x72.png") -Force
Copy-Item (Join-Path $RootDir "docs/Logos/Logo114x114.png") (Join-Path $BinIcons "Logo114x114.png") -Force
Copy-Item (Join-Path $RootDir "docs/Logos/Logo128x128.png") (Join-Path $BinIcons "Logo128x128.png") -Force

$descriptor = Get-Content $DescriptorTemplate -Raw
$descriptor = $descriptor.Replace("__AIR_NAMESPACE_VERSION__", $AirNamespaceVersion).
    Replace("__APP_ID__", $AppId).
    Replace("__VERSION__", $AppVersion).
    Replace("__FILENAME__", $AppFilename).
    Replace("__APP_NAME__", $AppName)
Set-Content -Path $DescriptorPath -Value $descriptor -Encoding utf8

$MainClassPath = $MainClass.Replace(".", "/") + ".as"
$MainClassFile = Join-Path $RootDir ("src/" + $MainClassPath)
if (-not (Test-Path $MainClassFile)) {
    throw "Main class nao encontrada: $MainClassFile"
}

Write-Host "Compilando SWF..."
& $Compiler `
    "+configname=air" `
    "-source-path+=$RootDir/src" `
    "-library-path+=$RootDir/lib" `
    "-library-path+=$RootDir/LachhhAds.swc" `
    -output "$OutputSwf" `
    "-target-player=25.0" `
    "-default-size=1280,720" `
    "-default-frame-rate=60" `
    "-static-link-runtime-shared-libraries=true" `
    "$MainClassFile"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not (Test-Path $CertPath)) {
    Write-Host "Gerando certificado de desenvolvimento local..."
    & $Adt -certificate -cn "LachhhTools Dev" 2048-RSA "$CertPath" "$CertPass"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

switch ($PackageTarget) {
    "bundle" { $PackageOutput = Join-Path $InstallersDir "LachhhTools.app" }
    "native" { $PackageOutput = Join-Path $InstallersDir "LachhhTools.exe" }
    "air" { $PackageOutput = Join-Path $InstallersDir "LachhhTools.air" }
    default { throw "PACKAGE_TARGET invalido: $PackageTarget (use bundle|native|air|auto)." }
}

Write-Host "Empacotando aplicacao ($PackageTarget)..."
& $Adt -package `
    -storetype pkcs12 `
    -keystore "$CertPath" `
    -storepass "$CertPass" `
    -tsa none `
    -target $PackageTarget `
    "$PackageOutput" `
    "$DescriptorPath" `
    -C "$BinDir" TwitchGiveawayTool.swf lachhhtools_widget.swf CustomAnimationExamples icons
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Build concluido:"
Write-Host "  SWF: $OutputSwf"
Write-Host "  Pacote: $PackageOutput"
