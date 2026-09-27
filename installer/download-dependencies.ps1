# download-dependencies.ps1
# Downloads LiquidLauncher and essential Fabric mods for the full installer
#
# Strategy: Only download what has stable predictable URLs:
# - LiquidLauncher from GitHub releases (always available)
# - Fabric API from FabricMC Maven (stable URL)
# - Fabric Kotlin from FabricMC Maven (stable URL)
# Other mods (Sodium, Lithium, etc.) will be auto-downloaded by LiquidLauncher
# on first launch.

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Version info (must match gradle/libs.versions.toml)
$versions = @{
    fabricApi      = "0.160.5+26.3"
    fabricKotlin   = "1.14.1+kotlin.2.4.20"
}

# URLs that we KNOW work
$downloads = @(
    @{
        Name = "LiquidLauncher"
        Url  = "https://github.com/CCBlueX/LiquidLauncher/releases/download/v0.6.1/LiquidLauncher_0.6.1_x64-setup.exe"
        Path = "LiquidLauncher-setup.exe"
        Required = $true
    },
    @{
        Name = "Fabric API"
        Url  = "https://maven.fabricmc.net/net/fabricmc/fabric-api/fabric-api/$($versions.fabricApi)/fabric-api-$($versions.fabricApi).jar"
        Path = "mods/Fabric API.jar"
        Required = $true
    },
    @{
        Name = "Fabric Kotlin"
        Url  = "https://maven.fabricmc.net/net/fabricmc/fabric-language-kotlin/$($versions.fabricKotlin)/fabric-language-kotlin-$($versions.fabricKotlin).jar"
        Path = "mods/Fabric Kotlin.jar"
        Required = $true
    }
)

Write-Host "============================================================"
Write-Host "  Downloading core dependencies for full LiquidBounce installer"
Write-Host "============================================================"
Write-Host ""

# Create mods subfolder
if (-not (Test-Path "mods")) {
    New-Item -ItemType Directory -Path "mods" | Out-Null
}

# Track results
$results = @()
$failed = @()

foreach ($item in $downloads) {
    Write-Host -NoNewline "[$($item.Name)] downloading... "

    try {
        $targetPath = $item.Path
        $targetDir = Split-Path $targetPath -Parent
        if (-not $targetDir) {
            # No parent directory - file goes to current dir
            $targetDir = "."
        }
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        # Download
        Invoke-WebRequest -Uri $item.Url -OutFile $targetPath -UseBasicParsing -TimeoutSec 120

        # Verify
        $size = (Get-Item $targetPath).Length
        if ($size -lt 1KB) {
            $msg = "Downloaded file too small ($size bytes)"
            Write-Host "FAILED ($msg)"
            $failed += $item.Name
            $results += [PSCustomObject]@{
                Name = $item.Name
                Size = "-"
                Path = $targetPath
                Status = "FAIL: $msg"
            }
            if ($item.Required) { throw $msg }
            continue
        }

        $sizeMB = "{0:N2}" -f ($size / 1MB)
        Write-Host "OK ($sizeMB MB)"
        $results += [PSCustomObject]@{
            Name = $item.Name
            Size = "$sizeMB MB"
            Path = $targetPath
            Status = "OK"
        }
    } catch {
        $msg = $_.Exception.Message
        $shortMsg = $msg.Substring(0, [Math]::Min(80, $msg.Length))
        Write-Host "FAILED ($shortMsg)"
        $failed += $item.Name
        $results += [PSCustomObject]@{
            Name = $item.Name
            Size = "-"
            Path = $item.Path
            Status = "FAIL: $shortMsg"
        }
        if ($item.Required) {
            Write-Host ""
            Write-Host "FATAL: Required download failed: $($item.Name)"
            Write-Host "URL: $($item.Url)"
            throw $msg
        }
    }
}

Write-Host ""
Write-Host "============================================================"
Write-Host "  Download Summary"
Write-Host "============================================================"
$results | Format-Table -AutoSize

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed downloads (non-fatal):"
    $failed | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
    Write-Host "Note: LiquidLauncher will auto-download missing mods on first launch."
}

Write-Host ""
Write-Host "Files ready for installer:"
Get-ChildItem -Recurse | Where-Object { -not $_.PSIsContainer } | Format-Table Name, @{Name="SizeMB";Expression={"{0:N2}" -f ($_.Length/1MB)}}, FullName -AutoSize
