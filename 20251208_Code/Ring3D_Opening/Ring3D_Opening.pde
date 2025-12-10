import processing.event.MouseEvent;  // 滾輪用

// ====== 基本參數 ======
int numLights = 20;        // 燈的數量（沿圓一圈）
float stageMargin = 80;    // 舞台左右預留空間
float lightWidth = 6;      // 每顆 pixel 在射線上的最大直徑
float lightHeight = 100;   // 每根燈柱的長度（沿射線方向）
int numSegments = 10;      // 每條燈切成幾個 pixel
float[][] brightness;      // brightness[i][s]：第 i 根燈、第 s 格的亮度

// ====== 相機控制 ======
float camRotX = -PI/6.0;  // 一開始稍微往後仰
float camRotY = 0;        // 左右旋轉
boolean isDragging = false;
int lastMouseX, lastMouseY;
float camZoom = 1.0;      // 鏡頭縮放倍率（1 = 原始大小）

// ====== 燈光語言相關變數 ======
int effectMode = 0;       // 0~12：各種燈光語言
String inputText = "";    // 使用者輸入的字串

// ====================== setup / draw ======================
void setup() {
  size(900, 480, P3D);          // 一定要 P3D 才能畫 sphere
  colorMode(HSB, 360, 100, 100);  
  rectMode(CENTER);
  textAlign(LEFT, TOP);
  textSize(16);

  brightness = new float[numLights][numSegments];
  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      brightness[i][s] = 40;  
    }
  }
}

void draw() {
  background(0);
  updateLights();            // 更新亮度

  noLights();                // 不用系統光源，維持純白球
  colorMode(HSB, 360, 100, 100);

  pushMatrix();
  // 先把舞台移到畫面偏下，像觀眾視角
  translate(width/2, height*0.65, 0);

  // 縮放：越大越近、越小越遠
  scale(camZoom);

  // 相機旋轉
  rotateX(camRotX);
  rotateY(camRotY);

  // 把座標系移回去，讓 drawLights3D / drawFloor 用 0~width,0~height 的邏輯
  translate(-width/2, -height/2, 0);

  // 先畫地板，再畫燈
  drawFloor();
  drawLights3D();

  popMatrix();
  
  // UI 疊在最上層
  hint(DISABLE_DEPTH_TEST);
  drawUI();
  hint(ENABLE_DEPTH_TEST);
}

// ====================== 燈光效果分流 ======================
void updateLights() {
  if (effectMode == 0) {
    updateCalm();            // 平靜
  } else if (effectMode == 1) {
    updateWave();            // 波浪
  } else if (effectMode == 2) {
    updateTense();           // 緊張
  } else if (effectMode == 3) {
    updateExpand();          // 擴張
  } else if (effectMode == 4) {
    updateWind();            // 風
  } else if (effectMode == 5) {
    updateFree();            // 自由
  } else if (effectMode == 6) {
    updateSeek();            // 追尋
  } else if (effectMode == 7) {
    updateClockwise();       // 順時針
  } else if (effectMode == 8) {
    updateCounterClockwise();// 逆時針
  } else if (effectMode == 9) {
    updateLookUp();          // 仰望
  } else if (effectMode == 10) {
    updateLookDown();        // 俯視
  } else if (effectMode == 11) {
    updateWake();            // 甦醒
  } else if (effectMode == 12) {
    updateBroken();          // 破碎
  }
}

// ====================== 各種效果（原樣保留） ======================

// 0. 平靜：整體緩慢呼吸
void updateCalm() {
  float t = frameCount * 0.02;
  float base = map(sin(t), -1, 1, 30, 80);  // 整體亮度

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float offset = (i + s) * 0.1;
      brightness[i][s] = constrain(base + 5 * sin(t + offset), 0, 100);
    }
  }
}

// 1. 波浪：沿 index 有流動感
void updateWave() {
  float t = frameCount * 0.08;
  for (int i = 0; i < numLights; i++) {
    float phaseX = i * 0.6;
    for (int s = 0; s < numSegments; s++) {
      float phaseY = s * 0.25;
      float v = sin(t + phaseX + phaseY);          // -1 ~ 1
      brightness[i][s] = map(v, -1, 1, 10, 100);
    }
  }
}

// 2. 緊張：隨機跳動＋閃爍
void updateTense() {
  float t = frameCount * 0.3;
  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float noiseVal = noise(i * 0.3, s * 0.4, t * 0.1);
      float flicker = (frameCount % 5 == 0) ? 100 : 40;
      brightness[i][s] = map(noiseVal, 0, 1, 20, flicker);
    }
  }
}

// 3. 擴張：從中間往兩側擴散
void updateExpand() {
  float t = frameCount * 0.04;

  float centerIndex = (numLights - 1) / 2.0;
  float maxRadius = numLights / 2.0 + 1;
  float radius = map(sin(t), -1, 1, 0, maxRadius);

  for (int i = 0; i < numLights; i++) {
    float dist = abs(i - centerIndex);

    for (int s = 0; s < numSegments; s++) {
      float edgeDiff = abs(dist - radius);
      float v = map(edgeDiff, 0, maxRadius, 100, 10);
      v = constrain(v, 10, 100);

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.7);
      brightness[i][s] = v * heightFactor;
    }
  }
}

// 4. 風：像一陣一陣風從側面掃過去
void updateWind() {
  float t = frameCount * 0.03;

  float bandCenter = map(sin(t * 0.7), -1, 1, -2, numLights + 1);
  float bandWidth = 3.0;

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float n = noise(i * 0.25 + t * 0.4, s * 0.15);
      float base = map(n, 0, 1, 15, 60);

      float dist = abs(i - bandCenter);
      float gust = map(dist, 0, bandWidth, 40, 0);
      if (gust < 0) gust = 0;

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.5);

      brightness[i][s] = constrain((base + gust) * heightFactor, 0, 100);
    }
  }
}

// 5. 自由：像光粒子自由漂流
void updateFree() {
  float t = frameCount * 0.015;

  float xSpeed = 0.006;
  float ySpeed = 0.009;
  float zSpeed = 0.0025;

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float nx = i * 0.22 + t * xSpeed * 150;
      float ny = s * 0.35 + t * ySpeed * 150;
      float nz = t * zSpeed * 300;

      float n = noise(nx, ny, nz);
      float base = map(n, 0, 1, 10, 100);

      float drift = sin(t + s * 0.8 + i * 0.3) * 10;

      brightness[i][s] = constrain(base + drift, 5, 100);
    }
  }
}

// 6. 追尋：一束光沿 index 來回掃描
void updateSeek() {
  float t = frameCount * 0.04;

  float seeker = map(sin(t), -1, 1, 0, numLights - 1);
  float beamWidth = 2.5;

  for (int i = 0; i < numLights; i++) {
    float dist = abs(i - seeker);

    for (int s = 0; s < numSegments; s++) {
      float edge = map(dist, 0, beamWidth, 100, 5);
      edge = constrain(edge, 5, 100);

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.6);

      float jitter = 0;
      if (dist < beamWidth * 0.7) {
        float jNoise = noise(i * 0.3, s * 0.5, t * 3.0);
        jitter = map(jNoise, 0, 1, -10, 10);
      }

      float bri = edge * heightFactor + jitter;
      brightness[i][s] = constrain(bri, 0, 100);
    }
  }
}

// 7. 順時針跑動：一顆沿圓順時針跑，有尾巴
void updateClockwise() {
  float speed = 0.4;  
  float head = (frameCount * speed) % numLights;
  float beamWidth = 3.5;

  for (int i = 0; i < numLights; i++) {
    float diff = abs(i - head);
    float dist = min(diff, numLights - diff);

    for (int s = 0; s < numSegments; s++) {
      float v = map(dist, 0, beamWidth, 100, 5);
      v = constrain(v, 5, 100);

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.6);
      brightness[i][s] = v * heightFactor;
    }
  }
}

// 8. 逆時針跑動
void updateCounterClockwise() {
  float speed = 0.4;
  float steps = (frameCount * speed) % numLights;
  float head  = (numLights - 1) - steps;
  float beamWidth = 3.5;

  for (int i = 0; i < numLights; i++) {
    float diff = abs(i - head);
    float dist = min(diff, numLights - diff);

    for (int s = 0; s < numSegments; s++) {
      float v = map(dist, 0, beamWidth, 100, 5);
      v = constrain(v, 5, 100);

      float heightFactor = map(s, 0, numSegments - 1, 1.0, 0.6);
      brightness[i][s] = v * heightFactor;
    }
  }
}

// 9. 仰望：從最底 pixel 一路往上灌滿
void updateLookUp() {
  float speed = 0.12;
  float level = (frameCount * speed) % (numSegments + 1);

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float bri;
      if (s <= level) {
        float edge = abs(s - level);
        bri = map(edge, 0, 1.5, 100, 70);
      } else {
        bri = 5;
      }
      brightness[i][s] = constrain(bri, 0, 100);
    }
  }
}

// 10. 俯視：從最頂端往下亮到最底（仰望相反）
void updateLookDown() {
  float speed = 0.12;
  float level = (frameCount * speed) % (numSegments + 1);

  for (int i = 0; i < numLights; i++) {
    for (int s = 0; s < numSegments; s++) {
      float bri;
      int topIndex = numSegments - 1 - s;

      if (topIndex <= level) {
        float edge = abs(topIndex - level);
        bri = map(edge, 0, 1.5, 100, 70);
      } else {
        bri = 5;
      }

      brightness[i][s] = constrain(bri, 0, 100);
    }
  }
}

// 11. 甦醒：LED 燈一支支隨機亮起 → 全亮 → 歸零 → 重來
void updateWake() {  
  float phaseFrames = 30.0;
  float allOnFrames = phaseFrames * numLights;
  float pauseFrames = 40.0;

  float cycleFrames = allOnFrames + pauseFrames;
  float t = frameCount % cycleFrames;

  randomSeed(9999);
  int[] order = new int[numLights];
  for (int i = 0; i < numLights; i++) order[i] = i;

  for (int i = numLights - 1; i > 0; i--) {
    int r = int(random(i + 1));
    int tmp = order[i];
    order[i] = order[r];
    order[r] = tmp;
  }

  for (int k = 0; k < numLights; k++) {
    int rank = 0;
    for (int i = 0; i < numLights; i++) {
      if (order[i] == k) {
        rank = i;
        break;
      }
    }

    float start = rank * phaseFrames;
    float end   = start + phaseFrames;

    float bri;
    if (t < start) {
      bri = 5;
    } else if (t < end) {
      float p = (t - start) / phaseFrames;
      bri = map(p, 0, 1, 5, 100);
    } else if (t < allOnFrames) {
      bri = 100;
    } else {
      bri = 5;
    }

    for (int s = 0; s < numSegments; s++) {
      brightness[k][s] = bri;
    }
  }
}

// 12. 破碎：
void updateBroken() {
  float speedStep = 0.2;
  int step = int(frameCount * speedStep) % (numLights + 1);

  randomSeed(9999);
  int[] order = new int[numLights];
  for (int i = 0; i < numLights; i++) order[i] = i;

  for (int i = numLights - 1; i > 0; i--) {
    int r = int(random(i + 1));
    int tmp = order[i];
    order[i] = order[r];
    order[r] = tmp;
  }

  float runSpeed = 0.15;
  float tailLen  = 2.0;

  for (int k = 0; k < numLights; k++) {

    boolean active = false;
    int rank = -1;
    for (int t = 0; t < step; t++) {
      if (order[t] == k) {
        active = true;
        rank = t;
        break;
      }
    }

    if (!active) {
      for (int s = 0; s < numSegments; s++) {
        brightness[k][s] = 5;
      }
      continue;
    }

    float head = (frameCount * runSpeed + rank * 0.5) % (numSegments + tailLen);

    for (int s = 0; s < numSegments; s++) {
      float dist = abs(s - head);
      float bri;
      if (dist <= tailLen) {
        bri = map(dist, 0, tailLen, 100, 20);
      } else {
        bri = 5;
      }
      brightness[k][s] = constrain(bri, 0, 100);
    }
  }
}

// ====================== 燈條 + 地板 ======================

// 一圈在地板上的正圓 + 直立燈條
void drawLights3D() {
  pushMatrix();
  noStroke();

  float stageLeft   = stageMargin;
  float stageRight  = width - stageMargin;
  float stageTop    = 80;
  float stageBottom = height - 180;  // 燈條底部高度，可調

  float segmentHeight = lightHeight / numSegments;

  // 地板上的圓（XZ 平面）
  float centerX = (stageLeft + stageRight) / 2.0;
  float centerZ = 0;

  float maxRadiusX = (stageRight - stageLeft) / 2.0;
  float radius = maxRadiusX * 0.9;

  float groundY = stageBottom;

  float dotRadius = min(lightWidth, segmentHeight) * 0.4;

  // ===== 這裡決定「只有 240° 有燈」、「留 120° 缺口」 =====
  float span = radians(240);          // 有燈的角度範圍
  float startAngle = -span/2.0;       // 讓 240° 對稱展開，缺口在相反那一側

  for (int i = 0; i < numLights; i++) {
    // ⭐ 把 0 ~ (numLights-1) 均勻映射到 240° 的弧形上
    float angle = map(i, 0, numLights-1, startAngle, startAngle + span);

    float baseX = centerX + cos(angle) * radius;
    float baseZ =           sin(angle) * radius;

    for (int s = 0; s < numSegments; s++) {
      float bri = brightness[i][s];
      fill(0, 0, bri);

      float y = groundY - (s + 0.5) * segmentHeight;

      pushMatrix();
      translate(baseX, y, baseZ);
      sphere(dotRadius);
      popMatrix();
    }
  }

  popMatrix();
}

// 3D 地板（矩形）
void drawFloor() {
  float stageTop    = 80;
  float stageBottom = height - 180;
  float groundY = stageBottom;

  pushMatrix();
  noStroke();
  fill(40);  // 深灰色

  float w = width * 1.0;
  float h = height * 4.0;

  translate(width/2, groundY, 0);
  rotateX(PI/2);

  rectMode(CENTER);
  rect(0, 0, w, h);

  popMatrix();
}

// ====================== UI：輸入文字 & 顯示模式 ======================
void drawUI() {
  fill(180);
  text("Enter > " + inputText, 20, 20);

  String modeName = "";
  if (effectMode == 0) modeName = "CALM";
  else if (effectMode == 1) modeName = "WAVE";
  else if (effectMode == 2) modeName = "TENSE";
  else if (effectMode == 3) modeName = "EXPAND";
  else if (effectMode == 4) modeName = "WIND";
  else if (effectMode == 5) modeName = "FREEDOM";
  else if (effectMode == 6) modeName = "SEEK";
  else if (effectMode == 7) modeName = "CLOCKWISE";
  else if (effectMode == 8) modeName = "COUNTERCLOCKWISE";
  else if (effectMode == 9) modeName = "LOOKUP";
  else if (effectMode == 10) modeName = "LOOKDOWN";
  else if (effectMode == 11) modeName = "WAKE";
  else if (effectMode == 12) modeName = "BROKEN";

  text("Current > " + modeName, 20, 40);
}

// ====================== 文字輸入 → 燈光字典 ======================
void keyPressed() {
  if (key == ENTER || key == RETURN) {
    String word = inputText.trim();
    applyKeyword(word);
    inputText = "";
  } 
  else if (key == BACKSPACE) {
    if (inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length()-1);
    }
  } 
  else if (key == CODED) {
    if (keyCode == LEFT)  camRotY -= 0.05;
    if (keyCode == RIGHT) camRotY += 0.05;
    if (keyCode == UP)    camRotX -= 0.05;
    if (keyCode == DOWN)  camRotX += 0.05;
  }
  else {
    inputText += key;
  }
}

// ====================== 滑鼠相機控制 ======================
void mousePressed() {
  isDragging = true;
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseReleased() {
  isDragging = false;
}

void mouseDragged() {
  if (isDragging) {
    float dx = mouseX - lastMouseX;
    float dy = mouseY - lastMouseY;

    camRotY += dx * 0.01;
    camRotX += dy * 0.01;

    lastMouseX = mouseX;
    lastMouseY = mouseY;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();  // 滾輪方向

  camZoom *= 1.0 + e * 0.05;
  camZoom = constrain(camZoom, 0.3, 3.0);
}

// ====================== 關鍵字對應 ======================
void applyKeyword(String word) {
  println("收到關鍵字：" + word);

  if (word.equals("平靜") || word.equalsIgnoreCase("calm")) {
    effectMode = 0;
  } 
  else if (word.equals("波浪") || word.equalsIgnoreCase("wave")) {
    effectMode = 1;
  } 
  else if (word.equals("緊張") || word.equalsIgnoreCase("tense")) {
    effectMode = 2;
  }
  else if (word.equals("擴張") || word.equalsIgnoreCase("expand")) {
    effectMode = 3;
  }
  else if (word.equals("風") || word.equalsIgnoreCase("wind")) {  
    effectMode = 4;
  }
  else if (word.equals("自由") || word.equalsIgnoreCase("freedom") || word.equalsIgnoreCase("free")) {
    effectMode = 5;
  }
  else if (word.equals("追尋") || word.equalsIgnoreCase("seek") || word.equalsIgnoreCase("search")) {
    effectMode = 6;   
  }
  else if (word.equals("順時針") || word.equalsIgnoreCase("clockwise") || word.equalsIgnoreCase("cw")) {
    effectMode = 7;
  }
  else if (word.equals("逆時針") || word.equalsIgnoreCase("counterclockwise") || word.equalsIgnoreCase("ccw")) {
    effectMode = 8;
  }
  else if (word.equals("仰望") || word.equalsIgnoreCase("lookup")  || word.equalsIgnoreCase("up")) {
    effectMode = 9;
  }
  else if (word.equals("俯視") || word.equals("俯瞰") || word.equalsIgnoreCase("lookdown") || word.equalsIgnoreCase("descend") || word.equalsIgnoreCase("down")) {
    effectMode = 10;
  }
  else if (word.equals("萌發") || word.equals("甦醒") || word.equalsIgnoreCase("germinate") || word.equalsIgnoreCase("init") || word.equalsIgnoreCase("spark") || word.equalsIgnoreCase("wake")) {
    effectMode = 11; 
  }
  else if (word.equals("破碎") || word.equalsIgnoreCase("broken")) {
    effectMode = 12; 
  }
  else {
    println("這個字還沒有對應的燈光語言，可以之後加進來。");
  }
}
