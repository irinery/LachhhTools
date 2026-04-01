param(
    [string]$RootDir = "",
    [string]$ValidationReportPath = ""
)

$ErrorActionPreference = "Stop"

if (-not $RootDir) {
    $RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

if (-not $ValidationReportPath) {
    $ValidationReportPath = Join-Path $RootDir "build/reports/windows-assets-validation.json"
}

$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Details
    )
    $checks.Add([pscustomobject]@{
        name = $Name
        passed = $Passed
        details = $Details
    }) | Out-Null
}

function Assert-Pattern {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Pattern
    )
    if (-not (Test-Path $Path -PathType Leaf)) {
        Add-Check -Name $Name -Passed $false -Details "Arquivo não encontrado: $Path"
        return
    }
    $match = Select-String -Path $Path -Pattern $Pattern -SimpleMatch -Quiet
    Add-Check -Name $Name -Passed $match -Details ($(if ($match) { "OK em $Path" } else { "Padrão ausente em $Path" }))
}

$exePath = Join-Path $RootDir "installers/LachhhTools.exe"
$swfPath = Join-Path $RootDir "bin/TwitchGiveawayTool.swf"

$exeExists = Test-Path $exePath -PathType Leaf
$swfExists = Test-Path $swfPath -PathType Leaf
Add-Check -Name "Windows executable exists" -Passed $exeExists -Details $exePath
Add-Check -Name "Main SWF exists" -Passed $swfExists -Details $swfPath

if ($exeExists) {
    $exeSize = (Get-Item $exePath).Length
    Add-Check -Name "Windows executable minimum size" -Passed ($exeSize -gt 1MB) -Details "Tamanho atual: $exeSize bytes"
}

$reportOk = $false
if (Test-Path $ValidationReportPath -PathType Leaf) {
    $validation = Get-Content $ValidationReportPath -Raw | ConvertFrom-Json
    $reportOk = ($validation.status -eq "ok")
}
Add-Check -Name "Asset validation report status" -Passed $reportOk -Details $ValidationReportPath

Assert-Pattern -Name "Startup updater flow" -Path (Join-Path $RootDir "src/com/flashinit/ReleaseInit.as") -Pattern "new UI_Updater("
Assert-Pattern -Name "Main menu flow" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/UI_Updater.as") -Pattern "new UI_Menu();"
Assert-Pattern -Name "Widget loader path" -Path (Join-Path $RootDir "src/com/flashinit/WidgetInWindow.as") -Pattern "aLoader.load(new URLRequest(""lachhhtools_widget.swf"")"
Assert-Pattern -Name "Giveaway module wired" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/ViewMenuUISelect.as") -Pattern "uiCrnt = new UI_GiveawayMenu();"
Assert-Pattern -Name "Alerts modules wired" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/ViewMenuUISelect.as") -Pattern "uiCrnt = new UI_FollowSubAlert();"
Assert-Pattern -Name "Help module wired" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/ViewMenuUISelect.as") -Pattern "uiCrnt = new UI_Help();"
Assert-Pattern -Name "PlayMovie module wired" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/ViewMenuUISelect.as") -Pattern "uiCrnt = new UI_PlayMovies();"
Assert-Pattern -Name "Persistence load path" -Path (Join-Path $RootDir "src/com/giveawaytool/meta/MetaGameProgress.as") -Pattern "public function loadFromLocal():void"
Assert-Pattern -Name "Persistence save path" -Path (Join-Path $RootDir "src/com/giveawaytool/meta/MetaGameProgress.as") -Pattern "public function saveToLocal():void"

$failed = @($checks | Where-Object { -not $_.passed })
$reportDir = Join-Path $RootDir "build/reports"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

$report = [pscustomobject]@{
    timestamp_utc = [DateTime]::UtcNow.ToString("o")
    status = $(if ($failed.Count -eq 0) { "ok" } else { "failed" })
    total_count = $checks.Count
    passed_count = $checks.Count - $failed.Count
    failed_count = $failed.Count
    checks = $checks
}

$jsonPath = Join-Path $reportDir "windows-critical-smoke.json"
$txtPath = Join-Path $reportDir "windows-critical-smoke.txt"
$report | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonPath -Encoding utf8

$txtLines = New-Object System.Collections.Generic.List[string]
$txtLines.Add("Windows Critical Smoke")
$txtLines.Add("Status: $($report.status)")
$txtLines.Add("Checks: $($report.total_count), Passed: $($report.passed_count), Failed: $($report.failed_count)")
$txtLines.Add("")
foreach ($check in $checks) {
    $flag = if ($check.passed) { "[OK]" } else { "[FAIL]" }
    $txtLines.Add("$flag $($check.name) - $($check.details)")
}
$txtLines | Set-Content -Path $txtPath -Encoding utf8

Write-Host "Relatório JSON: $jsonPath"
Write-Host "Relatório TXT:  $txtPath"

if ($failed.Count -gt 0) {
    foreach ($failure in $failed) {
        Write-Error ("Falha no smoke crítico: {0} - {1}" -f $failure.name, $failure.details)
    }
    exit 1
}

Write-Host "Smoke crítico de Windows concluído com sucesso."
