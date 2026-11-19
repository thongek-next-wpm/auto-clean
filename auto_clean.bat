@echo off
setlocal EnableExtensions

:: Capture carriage return (CR) for in-place progress updates
set "CR="
for /f %%A in ('copy /Z "%~f0" nul') do set "CR=%%A"

title Auto Clean - 0%%
echo ==================================================
echo  Auto Clean: Temp, Cache, and Recycle Bin
echo ==================================================
echo.

:: 1. Clear User Temporary Files
call :ShowProgress 5 "[1/5] Cleaning User Temp files..."
if defined TEMP call :CleanFolder "%TEMP%"
call :ShowProgress 12 "[1/5] Cleaning User Temp files..."
if defined TMP (
  if /i not "%TMP%"=="%TEMP%" call :CleanFolder "%TMP%"
)
call :ShowProgress 20 "[1/5] Cleaning User Temp files... Done!" DONE

:: 2. Clear Windows System Temp Files (Admin cleans system-owned files too)
call :ShowProgress 25 "[2/5] Cleaning Windows Temp files..."
if defined SystemRoot call :CleanFolder "%SystemRoot%\Temp"
call :ShowProgress 40 "[2/5] Cleaning Windows Temp files... Done!" DONE

:: 3. Clear Windows Caches & DNS Cache (Safe locations only)
call :ShowProgress 45 "[3/5] Cleaning Windows Cache..."
if defined LocalAppData (
  call :CleanFolder "%LocalAppData%\Microsoft\Windows\INetCache\IE"
  call :CleanFolder "%LocalAppData%\CrashDumps"
  call :ShowProgress 50 "[3/5] Cleaning Windows Cache (WER)..."
  call :CleanFolder "%LocalAppData%\Microsoft\Windows\WER\ReportArchive"
  call :CleanFolder "%LocalAppData%\Microsoft\Windows\WER\ReportQueue"
  call :ShowProgress 55 "[3/5] Cleaning Windows Cache (Thumbnails)..."
  if exist "%LocalAppData%\Microsoft\Windows\Explorer\." (
    del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
  )
)
ipconfig /flushdns >nul 2>&1
call :ShowProgress 60 "[3/5] Cleaning Windows Cache... Done!" DONE

:: 4. Clear Browser Caches (Cache only - keeps cookies, history, and passwords)
call :ShowProgress 64 "[4/5] Cleaning Browser Cache (Chrome)..."
if defined LocalAppData (
  if exist "%LocalAppData%\Google\Chrome\User Data\." (
    for /d %%P in ("%LocalAppData%\Google\Chrome\User Data\*") do (
      call :CleanFolder "%%P\Cache"
      call :CleanFolder "%%P\Code Cache"
      call :CleanFolder "%%P\GPUCache"
      call :CleanFolder "%%P\DawnGraphiteCache"
      call :CleanFolder "%%P\DawnWebGPUCache"
    )
    call :CleanFolder "%LocalAppData%\Google\Chrome\User Data\ShaderCache"
    call :CleanFolder "%LocalAppData%\Google\Chrome\User Data\GrShaderCache"
  ) 
  
  call :ShowProgress 69 "[4/5] Cleaning Browser Cache (Edge)..."
  if exist "%LocalAppData%\Microsoft\Edge\User Data\." (
    for /d %%P in ("%LocalAppData%\Microsoft\Edge\User Data\*") do (
      call :CleanFolder "%%P\Cache"
      call :CleanFolder "%%P\Code Cache"
      call :CleanFolder "%%P\GPUCache"
      call :CleanFolder "%%P\DawnGraphiteCache"
      call :CleanFolder "%%P\DawnWebGPUCache"
    )
    call :CleanFolder "%LocalAppData%\Microsoft\Edge\User Data\ShaderCache"
    call :CleanFolder "%LocalAppData%\Microsoft\Edge\User Data\GrShaderCache"
  )
  
  call :ShowProgress 74 "[4/5] Cleaning Browser Cache (Brave)..."
  if exist "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\." (
    for /d %%P in ("%LocalAppData%\BraveSoftware\Brave-Browser\User Data\*") do (
      call :CleanFolder "%%P\Cache"
      call :CleanFolder "%%P\Code Cache"
      call :CleanFolder "%%P\GPUCache"
    )
  )
  
  call :ShowProgress 77 "[4/5] Cleaning Browser Cache (Firefox)..."
  if exist "%LocalAppData%\Mozilla\Firefox\Profiles\." (
    for /d %%P in ("%LocalAppData%\Mozilla\Firefox\Profiles\*") do (
      call :CleanFolder "%%P\cache2"
      call :CleanFolder "%%P\startupCache"
    )
  )
)
call :ShowProgress 80 "[4/5] Cleaning Browser Cache... Done!" DONE

:: 5. Empty Recycle Bin (all drives, no confirmation)
call :ShowProgress 90 "[5/5] Emptying Recycle Bin..."
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Get-Command Clear-RecycleBin -ErrorAction SilentlyContinue) { Clear-RecycleBin -Force -ErrorAction SilentlyContinue }" >nul 2>&1
call :ShowProgress 100 "[5/5] Emptying Recycle Bin... Done!" DONE

echo.
echo ==================================================
echo  Cleanup completed! (100%%)
echo ==================================================
exit /b 0

:: --------------------------------------------------
:: Helper: Display a progress bar and percentage
:: Usage: call :ShowProgress <percent> "<message>" [DONE]
:: --------------------------------------------------
:ShowProgress
setlocal EnableDelayedExpansion
set /a "PCT=%~1"
if !PCT! lss 0 set /a "PCT=0"
if !PCT! gtr 100 set /a "PCT=100"
set /a "FILLED=PCT / 5"
set /a "EMPTY=20 - FILLED"
set "FULL_BAR=####################"
set "EMPTY_BAR=--------------------"
for %%F in (!FILLED!) do for %%E in (!EMPTY!) do (
  set "BAR=!FULL_BAR:~0,%%F!!EMPTY_BAR:~0,%%E!"
)
set "PCT_STR=  !PCT!"
set "PCT_STR=!PCT_STR:~-3!"
set "PAD=                                             "
set "MSG=%~2!PAD!"
set "MSG=!MSG:~0,45!"
title Auto Clean - !PCT!%%
if defined CR (
  <nul set /p "=[!BAR!] !PCT_STR!%% !MSG!!CR!"
  if /i "%~3"=="DONE" echo.
) else (
  if /i "%~3"=="DONE" echo [!BAR!] !PCT_STR!%% !MSG!
)
endlocal
goto :eof

:: --------------------------------------------------
:: Helper: Safely delete contents inside a folder
:: without deleting the folder itself.
:: --------------------------------------------------
:CleanFolder
set "TARGET=%~1"
if not defined TARGET goto :eof
if "%TARGET:~-1%"=="\" set "TARGET=%TARGET:~0,-1%"
if not defined TARGET goto :eof
:: Safety guards: require at least 4 chars and a backslash (never wipe drive root)
if "%TARGET:~3,1%"=="" goto :eof
if "%TARGET:\=%"=="%TARGET%" goto :eof
if not exist "%TARGET%\." goto :eof
del /f /s /q /a:-s "%TARGET%\*" >nul 2>&1
for /d %%D in ("%TARGET%\*") do rd /s /q "%%D" >nul 2>&1
goto :eof
