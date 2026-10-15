<#
.SYNOPSIS
  Установка портативного тулчейна (WinLibs MinGW-w64 GCC + CMake + Ninja + GDB) для лабораторных работ.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File install.ps1
  powershell -ExecutionPolicy Bypass -File install.ps1 -LocalSource \\server\share\labenv -PathScope Machine
#>
[CmdletBinding()]
param(
    [string]$InstallDir  = 'C:\labenv',
    [string]$CacheDir    = (Join-Path $env:TEMP 'labenv-cache'),
    [string]$LocalSource = '',
    [ValidateSet('User','Machine','None')][string]$PathScope = 'User',
    [switch]$Force
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'config.ps1')

function Get-FileResilient([string]$Url, [string]$Out) {
    for ($i = 1; $i -le 5; $i++) {
        try {
            if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                & curl.exe -L --fail --retry 3 --retry-delay 3 -C - -o $Out $Url
                if ($LASTEXITCODE -ne 0) { throw "curl exit code $LASTEXITCODE" }
            } else {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -Uri $Url -OutFile $Out -UseBasicParsing
            }
            return $true
        } catch {
            Write-Warning "Попытка $i не удалась: $_"
            Start-Sleep -Seconds (3 * $i)
        }
    }
    return $false
}

$mingwBin = Join-Path $InstallDir 'mingw64\bin'

if ((Test-Path (Join-Path $mingwBin 'g++.exe')) -and -not $Force) {
    Write-Host "Тулчейн уже установлен: $mingwBin"
} else {
    New-Item -ItemType Directory -Force -Path $InstallDir, $CacheDir | Out-Null
    $zip = Join-Path $CacheDir $Config.FileName
    $ok = $false

    if ($LocalSource) {
        $src = Join-Path $LocalSource $Config.FileName
        if (Test-Path $src) { Copy-Item $src $zip -Force; $ok = $true }
        else { Write-Warning "Не найден файл в локальном источнике: $src" }
    }
    if (-not $ok -and $Config.Sha256 -and (Test-Path $zip) -and ((Get-FileHash $zip -Algorithm SHA256).Hash -eq $Config.Sha256.ToUpper())) {
        $ok = $true
    }
    if (-not $ok) {
        foreach ($u in $Config.Urls) {
            Write-Host "Загрузка: $u"
            if (Get-FileResilient $u $zip) { $ok = $true; break }
        }
    }
    if (-not $ok) { throw 'Не удалось получить архив ни из одного источника. Используйте -LocalSource.' }

    $hash = (Get-FileHash $zip -Algorithm SHA256).Hash
    if ($Config.Sha256) {
        if ($hash -ne $Config.Sha256.ToUpper()) {
            Remove-Item $zip -Force
            throw "SHA256 не совпадает ($hash). Архив удалён, повторите установку."
        }
    } else {
        Write-Warning "Sha256 в config.ps1 не задан. SHA256 архива: $hash"
    }

    if (Test-Path (Join-Path $InstallDir 'mingw64')) { Remove-Item (Join-Path $InstallDir 'mingw64') -Recurse -Force }
    Write-Host 'Распаковка...'
    if (Get-Command tar.exe -ErrorAction SilentlyContinue) {
        & tar.exe -xf $zip -C $InstallDir
        if ($LASTEXITCODE -ne 0) { throw "tar exit code $LASTEXITCODE" }
    } else {
        Expand-Archive -Path $zip -DestinationPath $InstallDir -Force
    }
}

if ($PathScope -ne 'None') {
    $cur   = [Environment]::GetEnvironmentVariable('Path', $PathScope)
    $parts = @($cur -split ';' | Where-Object { $_ })
    if ($parts -notcontains $mingwBin) {
        [Environment]::SetEnvironmentVariable('Path', (($parts + $mingwBin) -join ';'), $PathScope)
        Write-Host "PATH ($PathScope) обновлён. Перезапустите терминал."
    }
}

$env:Path = "$mingwBin;$env:Path"
g++ --version | Select-Object -First 1
cmake --version | Select-Object -First 1
ninja --version
gdb --version | Select-Object -First 1
