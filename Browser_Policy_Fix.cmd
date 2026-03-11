:: Chrome 與 Edge 彈出式視窗及私有網路存取政策修復腳本
@echo off
setlocal EnableDelayedExpansion

:: 1. 檢查管理員權限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [錯誤] 請按右鍵選擇「以系統管理員身份執行」。
    pause
    exit /b 1
)

echo 正在檢查可處理的瀏覽器...
echo.

:: ================= 設定區塊 =================
:: 設定要加入白名單的網址 (建議使用 [*.] 格式)
set "url1=[*.]ncut.edu.tw"
set "url2=[*.]moica.nat.gov.tw"
set "url3=[*.]nat.gov.tw"
:: ==========================================

set /a processed_count=0
set /a skipped_count=0

call :process_browser "Google Chrome" "chrome.exe" "Software\Policies\Google\Chrome" "chrome://policy"
call :process_browser "Microsoft Edge" "msedge.exe" "Software\Policies\Microsoft\Edge" "edge://policy"

echo.
echo --------------------------------------------------
echo 處理完成。
echo 已套用政策的瀏覽器數量: %processed_count%
echo 已略過的瀏覽器數量: %skipped_count%
echo --------------------------------------------------
echo.
timeout /t 8 >nul
exit /b 0

:process_browser
set "browser_name=%~1"
set "process_name=%~2"
set "reg_root=%~3"
set "policy_url=%~4"

call :is_browser_installed "%process_name%"
if errorlevel 1 (
    echo [略過] %browser_name% 未安裝，跳過政策寫入。
    set /a skipped_count+=1
    echo.
    exit /b 0
)

echo 正在修正 %browser_name% 政策設定...

for %%R in (HKEY_LOCAL_MACHINE HKEY_CURRENT_USER) do (
    for %%P in (PopupsAllowedForUrls LocalNetworkAccessAllowedForUrls) do (
        set "keyPath=%%R\%reg_root%\%%P"
        echo 正在處理: !keyPath!

        reg delete "!keyPath!" /f >nul 2>&1
        reg add "!keyPath!" /f >nul

        if not "%url1%"=="" reg add "!keyPath!" /v "1" /t REG_SZ /d "%url1%" /f >nul
        if not "%url2%"=="" reg add "!keyPath!" /v "2" /t REG_SZ /d "%url2%" /f >nul
        if not "%url3%"=="" reg add "!keyPath!" /v "3" /t REG_SZ /d "%url3%" /f >nul

        echo [OK] %%R 寫入完成。
    )
)

echo.
echo --------------------------------------------------
echo [驗證] 檢查 HKLM 政策內容:
reg query "HKEY_LOCAL_MACHINE\%reg_root%\PopupsAllowedForUrls" 2>nul
echo --------------------------------------------------
echo.

echo 正在關閉 %browser_name% 以套用政策...
taskkill /F /IM %process_name% /T >nul 2>&1

echo 設定完成。
echo 請重新開啟 %browser_name%，並在網址列檢查 %policy_url%。
echo.

set /a processed_count+=1
exit /b 0

:is_browser_installed
set "target_process=%~1"

reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\App Paths\%target_process%" >nul 2>&1 && exit /b 0
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\%target_process%" >nul 2>&1 && exit /b 0

if /I "%target_process%"=="chrome.exe" (
    if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" exit /b 0
    if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" exit /b 0
)

if /I "%target_process%"=="msedge.exe" (
    if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" exit /b 0
    if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" exit /b 0
)

exit /b 1
