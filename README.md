# Light-simulation

# 20260105_Code

## Processing POV 文字掃描燈光模擬器

使用 Processing 製作的 3D 燈光視覺化程式，用來模擬 POV（Persistence of Vision，視覺暫留）形式的文字掃描效果。

程式會先把文字繪製到像素圖層中，再逐欄掃描文字影像，將掃描結果轉換成一排垂直燈柱的亮度變化，形成 LED 掃描文字的視覺效果。

---

## 功能特色

- 文字轉換成燈光掃描效果
- POV 視覺暫留風格模擬
- Processing `P3D` 3D 預覽
- 可調整燈柱數量與每條燈的分段數
- 支援滑鼠拖曳旋轉視角
- 支援滑鼠滾輪縮放視角
- 可設定殘影效果
- 可調整掃描速度、亮度、門檻值與顯示文字

---

## 概念說明

這個程式模擬一種「文字被燈光掃描出來」的效果。

運作流程大致如下：

1. 將指定文字繪製到一個 `PGraphics` 圖層中。
2. 程式逐欄掃描文字影像。
3. 每一欄的像素亮度會被轉換成 LED 分段亮度。
4. 掃描結果顯示在 3D 場景中的垂直燈柱上。
5. 透過連續掃描，形成文字被燈光顯現出來的效果。

---

## 執行需求

- Processing
- Java Mode
- Processing 3D Renderer：`P3D`
- `processing.event.MouseEvent`

目前版本不需要額外安裝外部函式庫。

---

## 主要參數

```java
String textToDisplay = "TIME";
int numLights = 20;
int numSegments = 10;
int scanSpeed = 1;
float threshold = 50;
float onBri = 100;
float offBri = 0;
float trail = 0;
