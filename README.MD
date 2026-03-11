# Chrome & Edge 瀏覽器政策調整工具

這是一組用於調整 **Google Chrome** 與 **Microsoft Edge** 政策設定的批次腳本，目的是快速處理特定網站在瀏覽器中因安全限制而無法正常運作的情況，例如：

- 私有網路存取 (`Private Network Access`) 被阻擋
- 彈出式視窗被瀏覽器封鎖

工具會透過寫入 Windows Registry Policy，將指定網站加入允許清單。

## 功能

- 檢查是否以系統管理員身份執行
- 同時寫入 `HKLM` 與 `HKCU` 的瀏覽器政策
- 預設加入以下網站：
  - `[*.]ncut.edu.tw`
  - `[*.]moica.nat.gov.tw`
  - `[*.]nat.gov.tw`
- 合併版會自動偵測 Chrome / Edge 是否安裝，未安裝則略過
- 執行開始前會提醒本工具可能關閉瀏覽器，確認後會於政策寫入完成後直接關閉相關程序，讓設定立即生效

## 檔案說明

- `Browser_Policy_Fix.cmd`
  - 新的合併版腳本
  - 會依序處理 Chrome 與 Edge
  - 如果某台電腦沒有安裝其中一個瀏覽器，會自動跳過
  - 全部處理完成後，會直接關閉已套用政策的瀏覽器
- `Chrome_Policy_Fix.cmd`
  - 原本的 Chrome 專用版本，保留相容用途
- `Edge_Policy_Fix.cmd`
  - 原本的 Edge 專用版本，保留相容用途

## 使用方式

1. 以系統管理員身份執行 `Browser_Policy_Fix.cmd`
2. 腳本會自動檢查 Chrome 與 Edge 是否存在
3. 已安裝的瀏覽器會寫入政策，未安裝的瀏覽器會略過
4. 腳本開始前會先提醒本工具可能關閉瀏覽器，確認後才繼續執行
5. 若有套用政策的瀏覽器存在，腳本完成後會直接關閉該瀏覽器，讓設定立即生效

若你只想單獨處理某一種瀏覽器，也可以繼續使用：

- `Chrome_Policy_Fix.cmd`
- `Edge_Policy_Fix.cmd`

## 驗證方式

- Chrome：開啟 `chrome://policy`
- Edge：開啟 `edge://policy`

確認 `PopupsAllowedForUrls` 與 `LocalNetworkAccessAllowedForUrls` 是否已出現設定值。

## 自訂允許網站

若要新增或更換允許清單，可修改腳本中的以下區塊：

```batch
set "url1=[*.]yourdomain.com"
set "url2=[*.]another-site.org"
set "url3=[*.]internal.example"
```

合併版與原本兩支單獨腳本都使用相同的網址設定方式。

## 注意事項

- 腳本會嘗試強制關閉瀏覽器程序，請先儲存工作
- 某些防毒軟體可能會攔截登錄檔政策修改
- 即使瀏覽器尚未安裝，對應政策理論上仍可先寫入；合併版選擇略過未安裝瀏覽器，主要是為了讓操作流程更清楚

## 免責聲明

本工具用於處理特定網站相容性與政策限制問題。修改瀏覽器政策可能影響安全性，請確認你信任要加入允許清單的網站。
