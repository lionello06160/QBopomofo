# QBopomofo — Q注音輸入法

QBopomofo 是一套 macOS 原生注音輸入法，使用 Rust 實作輸入引擎，並以 Swift、InputMethodKit 整合到 macOS。預設採用大千注音鍵盤，支援智慧選字、中英混排、自訂候選字視窗、Shift 中英切換、全形／半形輸入與 build-time 詞庫編譯。

本專案 fork 自 [tonyq-org/QBopomofo](https://github.com/tonyq-org/QBopomofo)，引擎核心與字詞庫資料源自 [Chewing（酷音）](https://chewing.im/) 開源專案，由 [libchewing Core Team](https://codeberg.org/chewing/libchewing) 及社群貢獻者長期維護。本 fork 已獨立發展，不是 tonyq-org/QBopomofo、libchewing 或 libchewing-data 的官方版本。

## 目前狀態

- 支援 macOS 13 以上版本。
- 目前從原始碼建置與安裝，尚未提供經 Apple notarize 的公開安裝包。
- 安裝腳本產生的是 ad-hoc signed `.app`，適合開發、測試與自用機器。
- 正式輸入法目前使用「Q注音」模式，也就是大千鍵盤、Chewing 選字與本專案的自訂詞頻。
- 字典在 build-time 編譯成 Trie 資料；正常打字時不解析 CSV，也不進行網路請求。
- 未開啟偵錯紀錄時，按鍵處理路徑不寫入 log。

## 快速安裝

### 系統需求

- macOS 13 或更新版本
- Git
- Xcode Command Line Tools，並包含 Swift 6.1 或更新版本
- Rust 1.88 或更新版本，以及 Cargo

先確認工具版本：

```bash
xcode-select -p
swift --version
rustc --version
cargo --version
git --version
```

如果尚未安裝 Xcode Command Line Tools：

```bash
xcode-select --install
```

Rust 可以透過 [rustup](https://rustup.rs/) 安裝，也可以使用 Homebrew：

```bash
brew install rust
```

若 `rustc --version` 低於 1.88，請先更新 Rust toolchain 再建置。

### 從原始碼安裝

```bash
git clone https://github.com/lionello06160/QBopomofo.git
cd QBopomofo/mac
./install.sh
```

`install.sh` 會依序完成：

1. 必要時建立預編譯字典資料。
2. 以 release 模式編譯 Rust 引擎與 C API 靜態函式庫。
3. 產生包含建置時間的 `BuildInfo.swift`。
4. 清除舊的 Swift build 產物並重新編譯 Swift 執行檔。
5. 組裝並 ad-hoc sign `QBopomofo.app`。
6. 停止舊的 QBopomofo 程序。
7. 安裝到 `~/Library/Input Methods/QBopomofo.app`。
8. 向 macOS 註冊輸入方式並啟動輸入法程序。

可用參數：

| 指令 | 用途 |
|------|------|
| `./install.sh` | release build、安裝、註冊並啟動 |
| `./install.sh --debug` | 安裝後以偵錯紀錄模式啟動 |
| `./install.sh --clean` | 接受此相容參數；目前標準 build 本來就會清除 `mac/.build` |
| `./install.sh --clean --debug` | 清除建置產物並以偵錯模式啟動 |

### 第一次啟用 Q注音

安裝腳本只負責安裝與註冊；第一次安裝仍需手動加入輸入方式：

1. 打開「系統設定」。
2. 選擇「鍵盤」。
3. 到「文字輸入」，按「編輯」。
4. 按左下角的 `+`。
5. 搜尋並加入 `Q注音`。
6. 從選單列的輸入法選單切換到 `Q注音`。

不同 macOS 版本的文字可能略有差異；可參考 Apple 的[「在 Mac 上更改輸入方式設定」](https://support.apple.com/zh-tw/guide/mac-help/-mchl84525d76/mac)。加入一次後，日後更新通常不需要重新加入。

## 實際輸入方式

### 大千注音鍵位

正式輸入法目前使用標準大千鍵盤：

| 實體鍵 | `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `9` | `0` | `-` |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 注音 | ㄅ | ㄉ | ˇ | ˋ | ㄓ | ˊ | ˙ | ㄚ | ㄞ | ㄢ | ㄦ |

| 實體鍵 | `q` | `w` | `e` | `r` | `t` | `y` | `u` | `i` | `o` | `p` |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 注音 | ㄆ | ㄊ | ㄍ | ㄐ | ㄔ | ㄗ | ㄧ | ㄛ | ㄟ | ㄣ |

| 實體鍵 | `a` | `s` | `d` | `f` | `g` | `h` | `j` | `k` | `l` | `;` |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 注音 | ㄇ | ㄋ | ㄎ | ㄑ | ㄕ | ㄘ | ㄨ | ㄜ | ㄠ | ㄤ |

| 實體鍵 | `z` | `x` | `c` | `v` | `b` | `n` | `m` | `,` | `.` | `/` |
|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 注音 | ㄈ | ㄌ | ㄏ | ㄒ | ㄖ | ㄙ | ㄩ | ㄝ | ㄡ | ㄥ |

空白鍵是第一聲。例如：

```text
hk4      → ㄘㄜˋ       → 測
g4       → ㄕˋ         → 試
hk4g4    → ㄘㄜˋ ㄕˋ   → 測試
```

### 基本組字操作

| 按鍵 | 組字時的行為 |
|------|--------------|
| `Enter` | 送出整段組字內容 |
| `Esc` | 清除目前尚未送出的整段組字內容 |
| `Backspace` | 刪除游標前一個注音、中文字或英文字元 |
| `Delete` | 刪除游標後一個中文字或英文字元 |
| `←` / `→` | 在組字內容中移動游標 |
| `↓` | 有中文組字時開啟候選字視窗 |
| `Home` / `End` | 移到中文組字區開頭／結尾 |
| `Page Up` / `Page Down` | 候選模式中切換候選頁 |

空白鍵會依目前狀態執行不同動作：

- 沒有組字內容時，輸入一般空白。
- 尚有一個注音音節未完成時，作為第一聲並完成該音節。
- 已有組字內容、但沒有待完成的注音時，在目前組字內容中插入空白。
- 候選字視窗已開啟時，切到下一頁候選字。

若要明確開啟候選字，請使用 `↓`。

### 候選字視窗

開啟候選字後：

| 按鍵 | 行為 |
|------|------|
| `↑` / `↓` | 移動目前頁面的反白候選字 |
| `Enter` | 選取目前反白的候選字 |
| 選字鍵 | 直接選取該位置的候選字；預設為 `1234567890` |
| `←` | 上一頁 |
| `→` 或 `Space` | 下一頁 |
| `Page Up` / `Page Down` | 上一頁／下一頁 |
| `Esc` | 關閉候選字視窗，不變更文字 |
| `Backspace` | 關閉候選字視窗，並刪除前一個組字內容 |

每頁候選字數與選字鍵可在 Q注音偏好設定中調整。

### Shift SmartToggle 與中英切換

預設 Shift 行為是 `SmartToggle`：

- **短按 Shift**：按下後直接放開，不輸入其他按鍵，會持續切換中文／英文模式。
- **按住 Shift 輸入英文字母**：暫時輸入英文；放開 Shift 後回到中文模式。
- **中文組字中切換英文**：英文會保留在同一段組字內容中，適合輸入 `測試API功能` 這類中英混排文字。
- **Enter**：依原本順序一次送出整段中英混排內容。
- **切換成功提示**：游標附近會短暫出現 `中` 或 `A` 指示。

按住 Shift 的暫時英文路徑只處理英文字母；數字若要作為英文內容插入，請先短按 Shift 切到英文模式再輸入。

Q注音刻意不把 Shift 當作英文字母大小寫鍵：

- Caps Lock 關閉時，按住 Shift 輸入小寫字母。
- Caps Lock 開啟時，按住 Shift 輸入大寫字母。

在偏好設定中改成「傳統切換」後，每次放開 Shift 都只切換中文／英文，不提供按住暫時英文的行為。

### Caps Lock 切換輸入方式

如果要使用 Caps Lock 在 Q注音與拉丁輸入方式之間切換，請使用 macOS 的系統選項：

1. 到「系統設定 → 鍵盤 → 文字輸入 → 編輯」。
2. 開啟「使用大寫鎖定鍵來切換上次使用的拉丁輸入方式和目前輸入方式」。

目前 Q注音偏好設定視窗雖然顯示「CapsLock 行為」，但 macOS 的 `InputController` 尚未套用這個內部選項；實際使用請以上述 macOS 系統設定為準。

### 全形／半形

按 `Shift + Space` 切換全形與半形模式。

全形模式下，可列印的 ASCII 字母、數字、空白與常用標點會轉換成全形字元，例如：

```text
ABC 123,.  →  ＡＢＣ　１２３，。
```

再按一次 `Shift + Space` 即切回半形。

### 中文標點快捷鍵

按住 `Control` 或 `Option` 搭配下列實體鍵，可直接把中文標點插入目前組字內容。若同時按住 `Command`，則不會攔截，讓 app 自己處理快捷鍵。

| 按鍵 | 輸出 | 按鍵 | 輸出 |
|------|------|------|------|
| `` Control/Option + ` `` | `‵` | `Control/Option + -` | `－` |
| `Control/Option + =` | `＝` | `Control/Option + \` | `＼` |
| `Control/Option + ,` | `，` | `Control/Option + .` | `。` |
| `Control/Option + /` | `？` | `Control/Option + ;` | `；` |
| `Control/Option + '` | `、` | `Control/Option + [` | `「` |
| `Control/Option + ]` | `」` | | |

一般 `Command` 快捷鍵及未列在上表的 `Control` 快捷鍵會交回目前使用的 app。

## 偏好設定

切換到 Q注音後，從選單列的輸入法選單開啟「偏好設定…」。設定變更會通知目前執行中的輸入控制器，不需要重新安裝。

| 設定 | 選項 | 預設值 | 說明 |
|------|------|--------|------|
| 每頁候選字數量 | `5`、`7`、`9` | `9` | 控制候選字視窗每頁最多顯示幾筆 |
| Shift 鍵行為 | SmartToggle、傳統切換 | SmartToggle | 控制短按切換與按住暫時英文 |
| 選字鍵 | `1234567890`、`asdfghjkl;` | `1234567890` | 候選字視窗的直接選字鍵 |
| CapsLock 行為 | 切換英文模式、不處理 | 切換英文模式 | 目前 macOS 控制層尚未套用，請用系統 Caps Lock 選項 |
| 空白鍵自動選字 | `0`～`3` 次 | `0` | 設定值會保存；目前 macOS 輸入路徑優先支援組字內空白，請用 `↓` 開啟候選字 |
| 保留偵錯紀錄 | 開／關 | 關 | 開啟後寫入 `/tmp/qbopomofo-*.log`，僅除錯時使用 |

設定儲存在目前使用者的 macOS `UserDefaults` 中。要查看目前值：

```bash
defaults read org.qbopomofo.inputmethod.QBopomofo
```

## 更新已安裝版本

在既有 clone 中更新：

```bash
cd /path/to/QBopomofo
git status --short
git pull --ff-only
./mac/install.sh
```

更新腳本會自動停止舊程序、覆蓋已安裝的 `.app`、重新註冊並啟動新程序。

`mac/build-app.sh` 每次建置都會把目前時間寫入 tracked file `mac/Sources/BuildInfo.swift`。如果你沒有刻意修改這個檔案，安裝後可先檢查，再還原單純的時間戳差異：

```bash
git diff -- mac/Sources/BuildInfo.swift
git restore -- mac/Sources/BuildInfo.swift
```

不要在有意修改 `BuildInfo.swift` 時執行最後一行。

## 驗證安裝結果

看到腳本輸出 `=== Installed ===` 只表示安裝流程已跑完；可再用以下指令確認實際狀態：

```bash
test -x "$HOME/Library/Input Methods/QBopomofo.app/Contents/MacOS/QBopomofo"
pgrep -x QBopomofo
plutil -extract CFBundleIdentifier raw -o - \
  "$HOME/Library/Input Methods/QBopomofo.app/Contents/Info.plist"
codesign --verify --deep --strict --verbose=2 \
  "$HOME/Library/Input Methods/QBopomofo.app"
```

預期 bundle identifier 為：

```text
org.qbopomofo.inputmethod.QBopomofo
```

也可以從輸入法選單打開「關於 Q注音」，確認版本與 build timestamp 是否為這次安裝的版本。

## 移除 Q注音

先切換到其他輸入方式，並在「系統設定 → 鍵盤 → 文字輸入 → 編輯」中移除 `Q注音`。

接著可在 Finder 將下列 app 移到垃圾桶：

```text
~/Library/Input Methods/QBopomofo.app
```

或使用終端機移除明確的安裝路徑：

```bash
pkill -f 'QBopomofo.app/Contents/MacOS/QBopomofo' 2>/dev/null || true
rm -rf "$HOME/Library/Input Methods/QBopomofo.app"
```

若還要清除 Q注音偏好設定，可另外執行：

```bash
defaults delete org.qbopomofo.inputmethod.QBopomofo
```

最後一個指令會刪除候選字數、Shift 行為、選字鍵與偵錯開關等個人設定。若輸入法仍暫時出現在選單中，請登出再登入 macOS。

## 開發操作

### 只建立 `.app`，不安裝

```bash
cd QBopomofo/mac
./build-app.sh
```

產物位置：

```text
mac/.build/QBopomofo.app
```

`build-app.sh` 會重建 Rust release 引擎與 Swift release 執行檔、複製字典和資源，最後進行 ad-hoc signing，但不會複製到 `~/Library/Input Methods/`，也不會替你切換目前使用的輸入法。

### 執行 TestApp

```bash
cd QBopomofo/mac/TestApp
./run.sh
```

需要完整清除 TestApp 的 Swift build 產物時：

```bash
./run.sh --clean
```

TestApp 可在不安裝系統輸入法的情況下測試：

- 注音組字與送字
- 候選字與模式切換
- Shift SmartToggle
- 中英混排
- 引擎按鍵耗時與畫面更新耗時
- 引擎日誌

TestApp 是開發用模擬器，包含尚未在正式 InputMethodKit 介面開放的模式與設定；最終輸入行為仍應在實際安裝的 Q注音中驗證。

### 執行 Rust 測試

```bash
cd QBopomofo/base/engine
cargo test --workspace
```

執行 release build：

```bash
cargo build --workspace --release
```

Rust 引擎改動後，不要只執行 `swift package clean && swift build`，因為這不保證更新 `libchewing_capi.a`。建議直接使用 `mac/build-app.sh`、`mac/install.sh` 或 `mac/TestApp/run.sh`；這三個腳本都會先重建 Rust C API。

### 重建字典與加入自訂詞彙

自訂詞彙放在 `data-provider/custom-data/*.csv`。目前主要檔案是 [`phrases.csv`](./data-provider/custom-data/phrases.csv)，格式如下：

```csv
詞,詞頻,注音1 注音2 ...
再試試,5000,ㄗㄞˋ ㄕˋ ㄕˋ
```

修改 CSV 後，手動重建資料：

```bash
cd QBopomofo/data-provider
./build.sh
```

輸出位於 `data-provider/output/`：

```text
word.dat
tsi.dat
symbols.dat
swkb.dat
```

接著重新安裝：

```bash
cd ../mac
./install.sh
```

`build-app.sh` 只有在 `data-provider/output/tsi.dat` 不存在時才自動執行資料 pipeline。因此，只要修改過自訂 CSV，就應先手動執行 `data-provider/build.sh`，否則現有 `.dat` 可能仍是舊詞庫。更多格式與詞頻說明請見 [`data-provider/custom-data/README.md`](./data-provider/custom-data/README.md)。

### 效能與依賴原則

打字反應速度是本專案的最高優先級：

- 按鍵到候選字的端到端延遲必須低於 5ms，目標低於 2ms。
- 按鍵 hot path 禁止 I/O、網路請求與動態文字資料轉換。
- CSV 合併、詞頻調整與 Trie 建立只能在 build-time 執行。
- 正常輸入時不得開啟持續偵錯紀錄。
- 候選字 UI 工作不得阻塞引擎的按鍵處理。

新增第三方依賴前，還必須確認 LGPL-2.1-or-later 授權相容性、保留原始授權，並更新 [`NOTICE`](./NOTICE)。Rust crate 應以 `cargo license` 審查完整授權鏈。

## 偵錯

### 啟用偵錯紀錄

```bash
cd QBopomofo/mac
./install.sh --debug
tail -f /tmp/qbopomofo.log
```

實際日期檔案格式為：

```text
/tmp/qbopomofo-YYYY-MM-DD.log
```

`/tmp/qbopomofo.log` 會連到當天的檔案。debug 啟動時，候選字修正也可能記錄在：

```text
/tmp/qbopomofo-corrections.log
```

也可以在 Q注音偏好設定中勾選「保留偵錯紀錄」，讓之後啟動的程序繼續保留 log。問題確認完畢後請關閉此選項，避免打字 hot path 持續進行檔案 I/O。

查看 macOS unified log：

```bash
log stream --style compact --predicate 'process == "QBopomofo"'
```

### 常見問題

#### `cargo: command not found`

Rust 尚未安裝，或 shell 的 `PATH` 尚未載入。先確認：

```bash
command -v cargo
rustc --version
```

#### `swift: command not found`

Xcode Command Line Tools 尚未安裝或目前 developer directory 不正確：

```bash
xcode-select --install
xcode-select -p
```

#### 安裝完成但找不到 Q注音

先確認 bundle 存在，再重新註冊：

```bash
test -d "$HOME/Library/Input Methods/QBopomofo.app"
"$HOME/Library/Input Methods/QBopomofo.app/Contents/MacOS/QBopomofo" install
```

然後回到「系統設定 → 鍵盤 → 文字輸入 → 編輯」按 `+`。如果仍未出現，可先關閉再重開「系統設定」，必要時登出再登入。

#### 已更新，但行為仍像舊版本

重新執行安裝腳本；它會停止舊程序並啟動新版本：

```bash
cd QBopomofo/mac
./install.sh --clean
pgrep -x QBopomofo
```

再從「關於 Q注音」核對 build timestamp。

#### `codesign` 回報 Finder information 或 resource fork

如果嚴格驗證出現 `resource fork, Finder information, or similar detritus not allowed`，可只清除已安裝 app 內的兩種延伸屬性，再重新 ad-hoc sign：

```bash
xattr -dr com.apple.FinderInfo \
  "$HOME/Library/Input Methods/QBopomofo.app"
xattr -dr com.apple.ResourceFork \
  "$HOME/Library/Input Methods/QBopomofo.app"
codesign --deep --force --sign - \
  "$HOME/Library/Input Methods/QBopomofo.app"
codesign --verify --deep --strict --verbose=2 \
  "$HOME/Library/Input Methods/QBopomofo.app"
```

上述操作只針對明確的 QBopomofo 安裝路徑，不要對整個 `~/Library` 遞迴清除延伸屬性。

## 專案結構

```text
QBopomofo/
├── base/engine/         # Rust 引擎核心與 C API
├── base/config/         # 輸入模式設定草案
├── data-provider/       # build-time 詞庫合併與 Trie 產生流程
├── mac/                 # Swift + InputMethodKit 實作、安裝與 TestApp
└── plans/               # 架構與驗證文件
```

延伸文件：

- [`plans/architecture.md`](./plans/architecture.md)：架構與資料流設計
- [`plans/validator.md`](./plans/validator.md)：手動輸入行為與迴歸驗證規則
- [`data-provider/custom-data/README.md`](./data-provider/custom-data/README.md)：自訂詞庫格式
- [`AGENTS.md`](./AGENTS.md)：開發、效能與授權規範

## 來源與授權

| 專案 | 說明 | 授權 | 備註 |
|------|------|------|------|
| [tonyq-org/QBopomofo](https://github.com/tonyq-org/QBopomofo) | Q注音輸入法原始專案 | LGPL-2.1-or-later | fork 後由本 repo 獨立維護 |
| [libchewing](https://codeberg.org/chewing/libchewing) | 智慧注音輸入法引擎 | LGPL-2.1 | [`100a0e0`](https://codeberg.org/chewing/libchewing/commit/100a0e09178532c570cc1680c97bc7541617426a)（2026-03-28） |
| [libchewing-data](https://codeberg.org/chewing/libchewing-data) | 字詞庫與詞頻資料 | LGPL-2.1 | [`dd81960`](https://codeberg.org/chewing/libchewing-data/commit/dd81960c90a75d07c3a80b542d721694cc034665)（2026-03-26） |

- `base/engine/` 的初始程式碼來自 libchewing，之後由本 repo 獨立維護。
- `data-provider/chewing-data/` 的 CSV 資料來自 libchewing-data，需要時由維護者手動同步。
- 引擎與資料不自動追蹤上游。
- 完整版權與第三方來源請見 [`NOTICE`](./NOTICE)。

本專案以 LGPL-2.1-or-later 授權釋出，詳見 [`LICENSE`](./LICENSE)。如果公開散布 `.app` 或其他二進位產物，請一併提供對應版本的原始碼取得方式，並保留 `LICENSE`、`NOTICE` 與第三方授權聲明。
