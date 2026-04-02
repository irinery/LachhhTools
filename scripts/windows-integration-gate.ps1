param(
    [string]$RootDir = ""
)

$ErrorActionPreference = "Stop"

if (-not $RootDir) {
    $RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
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

function Assert-File {
    param([string]$Name, [string]$Path)
    $exists = Test-Path $Path -PathType Leaf
    Add-Check -Name $Name -Passed $exists -Details $Path
}

function Assert-DirectoryWithFiles {
    param([string]$Name, [string]$Path)
    if (-not (Test-Path $Path -PathType Container)) {
        Add-Check -Name $Name -Passed $false -Details "Diretorio ausente: $Path"
        return
    }

    $children = @(Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue)
    Add-Check -Name $Name -Passed ($children.Count -gt 0) -Details ("Arquivos encontrados: {0}" -f $children.Count)
}

function Assert-Pattern {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Pattern
    )
    if (-not (Test-Path $Path -PathType Leaf)) {
        Add-Check -Name $Name -Passed $false -Details "Arquivo nao encontrado: $Path"
        return
    }

    $match = Select-String -Path $Path -Pattern $Pattern -SimpleMatch -Quiet
    Add-Check -Name $Name -Passed $match -Details ($(if ($match) { "OK em $Path" } else { "Padrao ausente em $Path" }))
}

$airHome = if ($env:AIR_HOME) { $env:AIR_HOME } elseif ($env:AIR_SDK_HOME) { $env:AIR_SDK_HOME } else { "" }
Add-Check -Name "AIR SDK configured" -Passed ([string]::IsNullOrWhiteSpace($airHome) -eq $false) -Details $(if ($airHome) { $airHome } else { "AIR_HOME/AIR_SDK_HOME nao definidos." })

if ($airHome) {
    $compilerCandidates = @(
        (Join-Path $airHome "bin/amxmlc.bat"),
        (Join-Path $airHome "bin/mxmlc.bat")
    )
    $compilerExists = $false
    foreach ($candidate in $compilerCandidates) {
        if (Test-Path $candidate -PathType Leaf) {
            $compilerExists = $true
            break
        }
    }
    Add-Check -Name "AIR compiler" -Passed $compilerExists -Details ($compilerCandidates -join " | ")
    Assert-File -Name "AIR package tool" -Path (Join-Path $airHome "bin/adt.bat")
}

Assert-File -Name "Build script (Windows)" -Path (Join-Path $RootDir "scripts/build.ps1")
Assert-File -Name "Descriptor template" -Path (Join-Path $RootDir "scripts/air-descriptor.template.xml")
Assert-File -Name "Widget source SWF" -Path (Join-Path $RootDir "platform/xSplitWidget/release/lachhhWidget.swf")
Assert-DirectoryWithFiles -Name "Custom animations seed" -Path (Join-Path $RootDir "bin/CustomAnimationExamples")

foreach ($icon in @(
    "docs/Logos/Logos16.png",
    "docs/Logos/Logos32_2.png",
    "docs/Logos/Logos36_2.png",
    "docs/Logos/Logos48_2.png",
    "docs/Logos/Logo72x72.png",
    "docs/Logos/Logo114x114.png",
    "docs/Logos/Logo128x128.png"
)) {
    Assert-File -Name "Icon asset" -Path (Join-Path $RootDir $icon)
}

Assert-Pattern -Name "Descriptor version placeholder" -Path (Join-Path $RootDir "scripts/air-descriptor.template.xml") -Pattern "__VERSION__"
Assert-Pattern -Name "Descriptor app name placeholder" -Path (Join-Path $RootDir "scripts/air-descriptor.template.xml") -Pattern "__APP_NAME__"
Assert-Pattern -Name "Startup updater flow" -Path (Join-Path $RootDir "src/com/flashinit/ReleaseInit.as") -Pattern "new UI_Updater("
Assert-Pattern -Name "Main menu flow" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/UI_Updater.as") -Pattern "new UI_Menu();"
Assert-Pattern -Name "Widget loader path" -Path (Join-Path $RootDir "src/com/flashinit/WidgetInWindow.as") -Pattern "aLoader.load(new URLRequest(""lachhhtools_widget.swf"")"
Assert-Pattern -Name "Giveaway module wired" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/ViewMenuUISelect.as") -Pattern "uiCrnt = new UI_GiveawayMenu();"
Assert-Pattern -Name "Alerts modules wired" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/ViewMenuUISelect.as") -Pattern "uiCrnt = new UI_FollowSubAlert();"
Assert-Pattern -Name "Help module wired" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/ViewMenuUISelect.as") -Pattern "uiCrnt = new UI_Help();"
Assert-Pattern -Name "PlayMovie module wired" -Path (Join-Path $RootDir "src/com/giveawaytool/ui/ViewMenuUISelect.as") -Pattern "uiCrnt = new UI_PlayMovies();"

$failed = @($checks | Where-Object { -not $_.passed })

if ($failed.Count -gt 0) {
    foreach ($failure in $failed) {
        Write-Error ("Falha no integration gate Windows: {0} - {1}" -f $failure.name, $failure.details)
    }
    exit 1
}

Write-Host "Integration gate Windows concluido com sucesso."
