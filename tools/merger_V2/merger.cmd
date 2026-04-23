@echo off
setlocal enabledelayedexpansion

@REM Merges all files listed in "listToMerge.txt" from ../src into ../CTLD_Next.lua
@REM Lines starting with "--" are treated as comments and skipped.
@REM Subdirectory paths (e.g. scenes/foo.lua) are resolved relative to src.
@REM --------------------------------------------------------------------

@REM Script directory (merger_V2/)
set "MERGER_DIR=%~dp0"

@REM Parent directory (repo root)
for %%A in ("%MERGER_DIR%..") do set "PARENT_DIR=%%~fA"

@REM Source directory (sibling of merger_V2)
set "SOURCE_DIR=%PARENT_DIR%\src"

@REM List file and output file
set "LIST=%MERGER_DIR%listToMerge.txt"
set "OUT=%PARENT_DIR%\CTLD_Next.lua"

if not exist "%LIST%" (
    echo [ERROR] %LIST% not found.
    pause
    exit /b
)

@REM Write VS Code/LuaLS exclusion headers
(
    echo ---@meta
    echo ---@diagnostic disable
    echo.
) > "%OUT%"

for /f "usebackq delims=" %%F in ("%LIST%") do (
    set "LINE=%%F"

    @REM Skip comment lines (starting with --)
    if "!LINE:~0,2!"=="--" (
        echo [SKIP] Comment: %%F
    ) else (
        set "FILE=%SOURCE_DIR%\%%F"
        if not exist "!FILE!" (
            echo [WARNING] File not found in src: %%F
        ) else (
            echo -- ==================================================================================================== >> "%OUT%"
            echo -- Start : %%F >> "%OUT%"
            type "!FILE!" >> "%OUT%"
            echo.>> "%OUT%"
            echo -- End : %%F >> "%OUT%"
        )
    )
)

echo.
echo Merged file generated: "%OUT%"
