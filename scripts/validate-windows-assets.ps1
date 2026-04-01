param(
    [string]$RootDir = "",
    [string]$BinDir = "",
    [string]$DescriptorPath = "",
    [string]$ReportDir = ""
)

$ErrorActionPreference = "Stop"

if (-not $RootDir) {
    $RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}
if (-not $BinDir) {
    $BinDir = Join-Path $RootDir "bin"
}
if (-not $DescriptorPath) {
    $DescriptorPath = Join-Path $BinDir "TwitchGiveawayTool-app.xml"
}
if (-not $ReportDir) {
    $ReportDir = Join-Path $RootDir "build/reports"
}

New-Item -ItemType Directory -Force -Path $ReportDir | Out-Null

$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [string]$Name,
        [string]$Path,
        [bool]$Passed,
        [string]$Details
    )
    $checks.Add([pscustomobject]@{
        name = $Name
        path = $Path
        passed = $Passed
        details = $Details
    }) | Out-Null
}

function Assert-File {
    param([string]$Name, [string]$Path)
    $exists = Test-Path $Path -PathType Leaf
    if (-not $exists) {
        Add-Check -Name $Name -Path $Path -Passed $false -Details "Arquivo obrigatório não encontrado."
        return
    }
    $size = (Get-Item $Path).Length
    if ($size -le 0) {
        Add-Check -Name $Name -Path $Path -Passed $false -Details "Arquivo encontrado, mas vazio."
        return
    }
    Add-Check -Name $Name -Path $Path -Passed $true -Details "OK ($size bytes)."
}

function Assert-Directory {
    param([string]$Name, [string]$Path)
    $exists = Test-Path $Path -PathType Container
    if (-not $exists) {
        Add-Check -Name $Name -Path $Path -Passed $false -Details "Diretório obrigatório não encontrado."
        return
    }
    $children = @(Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue)
    if ($children.Count -le 0) {
        Add-Check -Name $Name -Path $Path -Passed $false -Details "Diretório encontrado, mas vazio."
        return
    }
    Add-Check -Name $Name -Path $Path -Passed $true -Details "OK ($($children.Count) itens)."
}

Assert-File -Name "Main SWF" -Path (Join-Path $BinDir "TwitchGiveawayTool.swf")
Assert-File -Name "Widget SWF" -Path (Join-Path $BinDir "lachhhtools_widget.swf")
Assert-Directory -Name "CustomAnimationExamples" -Path (Join-Path $BinDir "CustomAnimationExamples")
Assert-Directory -Name "Icons folder" -Path (Join-Path $BinDir "icons")

$examplesDir = Join-Path $BinDir "CustomAnimationExamples"
if (Test-Path $examplesDir -PathType Container) {
    $swfExamples = @(Get-ChildItem -Path $examplesDir -File -Filter "*.swf" -ErrorAction SilentlyContinue)
    $flaExamples = @(Get-ChildItem -Path $examplesDir -File -Filter "*.fla" -ErrorAction SilentlyContinue)
    Add-Check -Name "CustomAnimationExamples SWF count" -Path $examplesDir -Passed ($swfExamples.Count -gt 0) -Details "Encontrados $($swfExamples.Count) SWFs."
    Add-Check -Name "CustomAnimationExamples FLA count" -Path $examplesDir -Passed ($flaExamples.Count -gt 0) -Details "Encontrados $($flaExamples.Count) FLAs."
}

$descriptorExists = Test-Path $DescriptorPath -PathType Leaf
Add-Check -Name "AIR descriptor" -Path $DescriptorPath -Passed $descriptorExists -Details ($(if ($descriptorExists) { "OK." } else { "Descriptor não encontrado." }))

if ($descriptorExists) {
    [string]$descriptorRaw = Get-Content $DescriptorPath -Raw
    $iconMatches = [regex]::Matches($descriptorRaw, "<image\d+x\d+>\s*([^<]+)\s*</image\d+x\d+>")
    if ($iconMatches.Count -eq 0) {
        Add-Check -Name "Descriptor icons declared" -Path $DescriptorPath -Passed $false -Details "Nenhum ícone declarado no descriptor."
    } else {
        Add-Check -Name "Descriptor icons declared" -Path $DescriptorPath -Passed $true -Details "$($iconMatches.Count) ícones declarados."
    }

    foreach ($icon in $iconMatches) {
        $relativeIconPath = $icon.Groups[1].Value.Trim()
        $resolvedIconPath = Join-Path $BinDir $relativeIconPath
        Assert-File -Name "Descriptor icon file" -Path $resolvedIconPath
    }
}

$report = [pscustomobject]@{
    timestamp_utc = [DateTime]::UtcNow.ToString("o")
    root_dir = $RootDir
    bin_dir = $BinDir
    descriptor_path = $DescriptorPath
    checks = $checks
}

$failed = @($checks | Where-Object { -not $_.passed })
$report | Add-Member -NotePropertyName "failed_count" -NotePropertyValue $failed.Count
$report | Add-Member -NotePropertyName "passed_count" -NotePropertyValue ($checks.Count - $failed.Count)
$report | Add-Member -NotePropertyName "total_count" -NotePropertyValue $checks.Count
$report | Add-Member -NotePropertyName "status" -NotePropertyValue ($(if ($failed.Count -eq 0) { "ok" } else { "failed" }))

$jsonPath = Join-Path $ReportDir "windows-assets-validation.json"
$txtPath = Join-Path $ReportDir "windows-assets-validation.txt"

$report | ConvertTo-Json -Depth 8 | Set-Content -Path $jsonPath -Encoding utf8

$txtLines = New-Object System.Collections.Generic.List[string]
$txtLines.Add("Windows Build Asset Validation")
$txtLines.Add("Status: $($report.status)")
$txtLines.Add("Checks: $($report.total_count), Passed: $($report.passed_count), Failed: $($report.failed_count)")
$txtLines.Add("")
foreach ($check in $checks) {
    $flag = if ($check.passed) { "[OK]" } else { "[FAIL]" }
    $txtLines.Add("$flag $($check.name)")
    $txtLines.Add("  Path: $($check.path)")
    $txtLines.Add("  Details: $($check.details)")
}
$txtLines | Set-Content -Path $txtPath -Encoding utf8

Write-Host "Relatório JSON: $jsonPath"
Write-Host "Relatório TXT:  $txtPath"

if ($failed.Count -gt 0) {
    foreach ($failure in $failed) {
        Write-Error ("Asset obrigatório ausente/inválido: {0} ({1})" -f $failure.name, $failure.path)
    }
    exit 1
}

Write-Host "Validação de assets concluída com sucesso."
