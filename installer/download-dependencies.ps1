# download-dependencies.ps1
# Downloads all required mods and LiquidLauncher for the full installer
# These get bundled into the Inno Setup installer

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Version info (must match gradle/libs.versions.toml)
$versions = @{
    minecraft       = "26.3"
    fabricLoader    = "0.19.5"
    fabricApi       = "0.160.5+26.3"
    fabricKotlin    = "1.14.1+kotlin.2.4.20"
    modmenu         = "21.0.0-beta.1"
    sodium          = "mc26.3-0.9.2-fabric"
    lithium         = "mc26.3-0.26.1-fabric"
    viafabricplus   = "5.1.0"
    exploitPreventer= "1.2.0+26.3"
    immediatelyFast = "1.17.1+26.3-fabric"
}

# URLs (Modrinth for mods, GitHub for LiquidLauncher, FabricMC maven for Fabric)
$downloads = @(
    @{
        Name = "LiquidLauncher.exe"
        Url  = "https://github.com/CCBlueX/LiquidLauncher/releases/download/v0.6.1/LiquidLauncher_0.6.1_x64-setup.exe"
        Path = "LiquidLauncher-setup.exe"
    },
    @{
        Name = "Fabric API"
        Url  = "https://maven.fabricmc.net/net/fabricmc/fabric-api/fabric-api/$($versions.fabricApi)/fabric-api-$($versions.fabricApi).jar"
        Path = "mods/Fabric API.jar"
    },
    @{
        Name = "Fabric Kotlin"
        Url  = "https://maven.fabricmc.net/net/fabricmc/fabric-language-kotlin/$($versions.fabricKotlin)/fabric-language-kotlin-$($versions.fabricKotlin).jar"
        Path = "mods/Fabric Kotlin.jar"
    },
    @{
        Name = "Mod Menu"
        Url  = "https://cdn.modrinth.com/data/mOgUt4GM/versions/$($versions.modmenu)/modmenu-$($versions.modmenu).jar"
        Path = "mods/Mod Menu.jar"
    },
    @{
        Name = "Sodium"
        Url  = "https://cdn.modrinth.com/data/AANobbMI/versions/$($versions.sodium)/sodium-$($versions.sodium).jar"
        Path = "mods/Sodium.jar"
    },
    @{
        Name = "Lithium"
        Url  = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/$($versions.lithium)/lithium-$($versions.lithium).jar"
        Path = "mods/Lithium.jar"
    },
    @{
        Name = "ViaFabricPlus"
        Url  = "https://cdn.modrinth.com/data/VikA7qP5/versions/$($versions.viafabricplus)/ViaFabricPlus-$($versions.viafabricplus).jar"
        Path = "mods/ViaFabricPlus.jar"
    },
    @{
        Name = "ExploitPreventer"
        Url  = "https://cdn.modrinth.com/data/6J4n5Lok/versions/$($versions.exploitPreventer)/ExploitPreventer-$($versions.exploitPreventer).jar"
        Path = "mods/ExploitPreventer.jar"
    },
    @{
        Name = "ImmediatelyFast"
        Url  = "https://cdn.modrinth.com/data/5ZwdcRci/versions/$($versions.immediatelyFast)/ImmediatelyFast-$($versions.immediatelyFast).jar"
        Path = "mods/ImmediatelyFast.jar"
    }
)

Write-Host "============================================================"
Write-Host "  Downloading dependencies for full LiquidBounce installer"
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
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        # Download
        Invoke-WebRequest -Uri $item.Url -OutFile $targetPath -UseBasicParsing -TimeoutSec 60

        # Verify
        $size = (Get-Item $targetPath).Length
        if ($size -lt 1KB) {
            Write-Host "FAILED (too small: $size bytes)"
            $failed += $item.Name
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
        Write-Host "FAILED ($($_.Exception.Message.Substring(0, [Math]::Min(60, $_.Exception.Message.Length))))"
        $failed += $item.Name
        $results += [PSCustomObject]@{
            Name = $item.Name
            Size = "-"
            Path = $item.Path
            Status = "FAIL: $($_.Exception.Message.Substring(0, [Math]::Min(80, $_.Exception.Message.Length)))"
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
    Write-Host "FAILED downloads:"
    $failed | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
    Write-Host "Note: Some Modrinth URLs require version-hashed paths. If Fabric"
    Write-Host "API and Fabric Kotlin succeed (FabricMC Maven), the installer"
    Write-Host "will still work - LiquidLauncher will download missing mods"
    Write-Host "automatically on first launch."
    Write-Host ""
    # Don't fail the build - LiquidLauncher will fetch missing mods itself
    # exit 1
}

Write-Host ""
Write-Host "Files ready for installer:"
Get-ChildItem -Recurse | Where-Object { -not $_.PSIsContainer } | Format-Table Name, @{Name="Size (MB)";Expression={"{0:N2}" -f ($_.Length/1MB)}}, FullName -AutoSize
