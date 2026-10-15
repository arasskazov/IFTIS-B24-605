# Проверка окружения: сборка и запуск многопоточного тестового проекта.
$ErrorActionPreference = 'Stop'
$dir = if ($env:LABENV_DIR) { $env:LABENV_DIR } else { 'C:\labenv' }
$env:Path = "$dir\mingw64\bin;$env:Path"
$src   = Join-Path $PSScriptRoot 'test'
$build = Join-Path $env:TEMP 'labenv-verify'

cmake -S $src -B $build -G Ninja -DCMAKE_BUILD_TYPE=Release
if ($LASTEXITCODE) { throw 'Ошибка конфигурации CMake' }
cmake --build $build
if ($LASTEXITCODE) { throw 'Ошибка сборки' }
& (Join-Path $build 'thread_test.exe')
if ($LASTEXITCODE) { throw 'Тестовая программа завершилась с ошибкой' }
Write-Host 'Окружение готово.'
