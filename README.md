# 20251124_Code

# 20251201_Code

## Processing 2D 燈光語言模擬

使用者可以輸入中文或英文關鍵字，程式會根據輸入內容切換不同的燈光動態。  
燈光有 6 種的排列方式，每一根燈柱由多個 pixel segment 組成，透過亮度變化呈現不同的情緒、動作與意象。

---

### 功能特色

- 中文 / 英文關鍵字輸入
- 13 種燈光語言模式
- 6 種燈光排列形式
- 每根燈柱可分段控制亮度
- 支援呼吸、波浪、閃爍、擴散、旋轉、上升、下降等效果

---

### 執行需求

- Processing
- Java Mode

目前版本不需要額外安裝外部函式庫。

---

### 基本參數

```java
int numLights = 20;
int numSegments = 10;
float stageMargin = 80;
float lightWidth = 6;
float lightHeight = 100;
```

# 20251208_Code

## Processing 3D 燈光語言模擬

程式會將多根燈柱排列成 7 種結構，每根燈柱由多個 pixel segment 組成。使用者可以輸入中文或英文關鍵字，讓系統切換不同的燈光動態，例如平靜、波浪、緊張、擴張、風、自由、追尋、順時針、逆時針、仰望、俯視、甦醒與破碎。

---

### 功能特色

- 使用 Processing `P3D` 建立 3D 燈光預覽
- 7 種排列形式
- 每根燈柱由多個 pixel segment 組成
- 支援 13 種燈光語言模式
- 支援中文與英文關鍵字輸入
- 支援滑鼠拖曳旋轉視角
- 支援滑鼠滾輪縮放
- 支援鍵盤方向鍵微調視角

---

### 畫面概念

每個燈光效果會改變 `brightness[i][s]` 的數值：

```java
brightness[i][s]
```

# 20260105_Code

## Processing POV 文字掃描燈光模擬

使用 Processing 製作的 3D 燈光視覺化程式，用來模擬 POV（Persistence of Vision，視覺暫留）形式的文字掃描效果。

程式會先把文字繪製到像素圖層中，再逐欄掃描文字影像，將掃描結果轉換成一排垂直燈柱的亮度變化，形成 LED 掃描文字的視覺效果。

---

### 功能特色

- 文字轉換成燈光掃描效果
- POV 視覺暫留風格模擬
- Processing `P3D` 3D 預覽
- 可調整燈柱數量與每條燈的分段數
- 支援滑鼠拖曳旋轉視角
- 支援滑鼠滾輪縮放視角
- 可設定殘影效果
- 可調整掃描速度、亮度、門檻值與顯示文字

---

### 運作流程

1. 將指定文字繪製到一個 `PGraphics` 圖層中。
2. 程式逐欄掃描文字影像。
3. 每一欄的像素亮度會被轉換成 LED 分段亮度。
4. 掃描結果顯示在 3D 場景中的垂直燈柱上。
5. 透過連續掃描，形成文字被燈光顯現出來的效果。

---

### 執行需求

- Processing
- Java Mode
- Processing 3D Renderer：`P3D`
- `processing.event.MouseEvent`

目前版本不需要額外安裝外部函式庫。

---

### 主要參數

```java
String textToDisplay = "TIME";
int numLights = 20;
int numSegments = 10;
int scanSpeed = 1;
float threshold = 50;
float onBri = 100;
float offBri = 0;
float trail = 0;
