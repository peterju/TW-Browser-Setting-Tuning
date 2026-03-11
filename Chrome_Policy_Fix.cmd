:: Google Chrome 彈出式視窗與私有網路存取政策修復腳本
@echo off
setlocal EnableDelayedExpansion

:: 1. 檢查管理員權限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [錯誤] 請按右鍵選擇「以系統管理員身份執行」。
    pause
    exit /b 1
)

echo 正在修正 Google Chrome 政策設定...

:: ================= 設定區塊 =================
:: 設定要加入白名單的網址 (建議使用 [*.] 格式)
set "browser_name=Google Chrome"
set "process_name=chrome.exe"
set "reg_root=Software\Policies\Google\Chrome"

set "url1=[*.]ncut.edu.tw"
set "url2=[*.]moica.nat.gov.tw"
set "url3=[*.]nat.gov.tw"
:: ==========================================

:: 2. 處理 HKLM 與 HKCU 登錄檔寫入
for %%R in (HKEY_LOCAL_MACHINE HKEY_CURRENT_USER) do (
    :: 同時處理彈出視窗(p1)與區域網路存取(p2)
    for %%P in (PopupsAllowedForUrls LocalNetworkAccessAllowedForUrls) do (
        set "keyPath=%%R\%reg_root%\%%P"
        echo 正在處理: !keyPath!
        
        :: 先刪除舊機碼確保索引乾淨並重建
        reg delete "!keyPath!" /f >nul 2>&1
        reg add "!keyPath!" /f >nul

        :: 逐筆寫入網址
        if not "%url1%"=="" reg add "!keyPath!" /v "1" /t REG_SZ /d "%url1%" /f >nul
        if not "%url2%"=="" reg add "!keyPath!" /v "2" /t REG_SZ /d "%url2%" /f >nul
        if not "%url3%"=="" reg add "!keyPath!" /v "3" /t REG_SZ /d "%url3%" /f >nul
        
        echo [OK] %%R 寫入完成。
    )
)

echo.
echo --------------------------------------------------
echo [驗證] 檢查 HKLM 政策內容：
reg query "HKEY_LOCAL_MACHINE\%reg_root%\PopupsAllowedForUrls" 2>nul
echo --------------------------------------------------
echo.

:: 3. 強制結束進程以套用政策
echo 正在強制重啟 %browser_name% 以套用政策...
taskkill /F /IM %process_name% /T >nul 2>&1

echo.
echo 設定完成！
echo 請重新開啟 %browser_name%，並在網址列檢查 chrome://policy。
timeout 8