# QBopomofo — Q注音輸入法

跨平台注音輸入法專案，目前包含 macOS 實作與 Windows TSF 實作。macOS 安裝流程較完整；Windows 版仍建議視為開發/測試狀態。

本專案 fork 自 [tonyq-org/QBopomofo](https://github.com/tonyq-org/QBopomofo)，其引擎核心與字詞庫資料源自 [Chewing（酷音）](https://chewing.im/) 開源專案，由 [libchewing Core Team](https://codeberg.org/chewing/libchewing) 及社群貢獻者多年維護。本 fork 在此基礎上進行獨立發展。

本 fork 不是 tonyq-org/QBopomofo、libchewing 或 libchewing-data 的官方版本。

## 來源與授權

本專案源自以下開源專案：

| 專案 | 說明 | 授權 | 備註 |
|------|------|------|--------|
| [tonyq-org/QBopomofo](https://github.com/tonyq-org/QBopomofo) | Q注音輸入法原始專案 | LGPL-2.1-or-later | fork 後由本 repo 獨立維護 |
| [libchewing](https://codeberg.org/chewing/libchewing) | 智慧注音輸入法引擎 | LGPL-2.1 | [`100a0e0`](https://codeberg.org/chewing/libchewing/commit/100a0e09178532c570cc1680c97bc7541617426a)（2026-03-28） |
| [libchewing-data](https://codeberg.org/chewing/libchewing-data) | 字詞庫與詞頻資料 | LGPL-2.1 | [`dd81960`](https://codeberg.org/chewing/libchewing-data/commit/dd81960c90a75d07c3a80b542d721694cc034665)（2026-03-26） |

> fork 後的額外修改由本 repo 維護；引擎與資料若需要同步上游，需手動更新。

## 專案結構

```
QBopomofo/
├── base/engine/         # 引擎核心（源自 libchewing，獨立發展）
├── base/config/         # 模式設定檔草案
├── data-provider/       # 資料隔離層（build-time 處理 pipeline）
├── mac/                 # macOS 實作（Swift + InputMethodKit）
├── win/                 # Windows TSF 實作（開發/測試中）
└── plans/               # 架構文件
```

## macOS 安裝

需求：

- macOS 13 以上
- Xcode Command Line Tools
- Swift 6.1 以上
- Rust toolchain

### Apple Silicon / M 系列 Mac 從零安裝

如果另一台 Mac 還沒有安裝開發環境，先執行：

```bash
xcode-select --install
```

如需安裝 Homebrew：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

安裝 Rust：

```bash
brew install rust
```

確認工具可用：

```bash
swift --version
rustc --version
cargo --version
```

### 安裝 Q注音

在目標 Mac 上執行：

```bash
git clone https://github.com/lionello06160/QBopomofo.git
cd QBopomofo/mac
./install.sh
```

安裝完成後，到「系統設定 → 鍵盤 → 輸入方式 → +」加入 `Q注音`。

如果是使用 Homebrew 安裝 Rust（特別是 Apple Silicon / `/opt/homebrew` 環境），目前 repo 已內建處理 Swift build plugin 的 PATH，不需要額外手動設定 `rustc` 路徑。

### 安裝後啟用

1. 打開「系統設定 → 鍵盤 → 輸入方式」
2. 按 `+`
3. 加入 `Q注音`
4. 切換到 `Q注音` 開始使用

如果安裝後沒有立刻出現在輸入方式清單：

- 先完全退出正在使用的 app 再重新打開
- 重新切換一次輸入法
- 必要時登出再登入 macOS

### 重新安裝 / 更新

如果你已經 clone 過 repo，之後更新只要：

```bash
cd QBopomofo
git pull
cd mac
./install.sh
```

### 建立 `.app` bundle

如果只要產生 macOS input method app bundle，可以執行：

```bash
cd QBopomofo/mac
./build-app.sh
```

產生出的檔案會在：

```bash
mac/.build/QBopomofo.app
```

這是未 notarize 的 app bundle，適合內部測試或自用機器。使用 `./install.sh` 安裝時，app 會被放到：

```bash
~/Library/Input Methods/QBopomofo.app
```

安裝完成後，仍需到「系統設定 → 鍵盤 → 輸入方式 → +」手動加入 `Q注音`。

## Windows 版狀態

`win/` 目錄包含 Windows TSF Text Service 實作與安裝腳本：

```powershell
cd QBopomofo\win
.\install.bat
```

Windows 版目前偏開發/測試用途，建議先在 Windows 測試機或 Windows Sandbox 驗證。安裝腳本會建置並註冊 TSF DLL；正式散布前仍需確認字典資料檔、安裝流程與移除流程都符合目標環境。

### 常見問題

`cargo: command not found`

- 代表 Rust 尚未安裝，請先執行 `brew install rust`

`swift: command not found`

- 代表 Xcode Command Line Tools 尚未安裝，請先執行 `xcode-select --install`

安裝成功但無法切到 `Q注音`

- 先到「系統設定 → 鍵盤 → 輸入方式」確認已加入 `Q注音`
- 如果已加入但 app 內無法使用，先完全退出該 app 再重新開啟

## 與上游的關係

- 本專案 fork 自 [tonyq-org/QBopomofo](https://github.com/tonyq-org/QBopomofo)，fork 後的額外修改由本 repo 維護
- `base/engine/` 的初始程式碼來自 libchewing，之後由本 repo 維護
- `data-provider/chewing-data/` 的 CSV 資料來自 libchewing-data，可視需要手動同步
- 詳見 [NOTICE](./NOTICE) 了解完整版權聲明

## 發布注意事項

如果你要公開原始碼或散布 `.app` / `.pkg` 安裝檔，請一併保留並提供：

- [LICENSE](./LICENSE)
- [NOTICE](./NOTICE)
- 本 repo 的原始碼網址或對應 release/tag

本專案依 LGPL-2.1-or-later 授權釋出；如果散布二進位檔，接收者也應能取得對應版本的原始碼。

## 授權

本專案以 LGPL-2.1-or-later 授權釋出。詳見 [LICENSE](./LICENSE)。
