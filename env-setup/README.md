# Окружение для лабораторных работ (Windows)

Портативный тулчейн WinLibs: GCC 16.2.0 (POSIX threads, UCRT), GDB, GNU Make, CMake, Ninja, Cppcheck. Установка не требует MSVC и Docker.

## Быстрый старт

```powershell
powershell -ExecutionPolicy Bypass -File env-setup\install.ps1
powershell -ExecutionPolicy Bypass -File env-setup\verify.ps1
```

## Варианты

| Сценарий | Команда |
|---|---|
| Для всех пользователей машины (нужны права администратора) | `install.ps1 -PathScope Machine` |
| Без изменения PATH (только текущая сессия) | `install.ps1 -PathScope None`, затем `env-setup\env.cmd` |
| GitHub недоступен: архив лежит на сетевом диске | `install.ps1 -LocalSource \\server\share\labenv` |
| Переустановка | `install.ps1 -Force` |

Загрузка идёт через `curl.exe` с докачкой и 5 повторными попытками, что полезно при нестабильном доступе к GitHub.

## Настройка

Версия, имя файла, ссылки и SHA256 задаются в `config.ps1`. Добавьте внутреннее зеркало первым в `$Config.Urls`. Хеш берите из файла `.sha256` на странице релиза [winlibs_mingw](https://github.com/brechtsanders/winlibs_mingw/releases).

## Проверка

`verify.ps1` собирает `test/` через CMake и Ninja и запускает программу с потоками, `std::mutex` и `std::atomic`.
