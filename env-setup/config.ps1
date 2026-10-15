# Конфигурация окружения лабораторных работ.
# WinLibs-бандл включает GCC, GDB, GNU Make, CMake, Ninja, Cppcheck, ccache.
$Config = @{
    Version  = '16.2.0posix-14.0.0-ucrt-r2'
    FileName = 'winlibs-x86_64-posix-seh-gcc-16.2.0-mingw-w64ucrt-14.0.0-r2.zip'
    # SHA256 берётся из файла .sha256 рядом с архивом на странице релиза. Пустое значение = без проверки.
    Sha256   = ''
}

# Список источников по порядку. Добавьте зеркало (например, внутренний сервер вуза) первым.
$Config.Urls = @(
    "https://github.com/brechtsanders/winlibs_mingw/releases/download/$($Config.Version)/$($Config.FileName)"
)
