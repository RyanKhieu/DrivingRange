// map constants
final float GROUND_Y = 500;
final float TEE_WORLD_X = 100;
final float TEE_Y = GROUND_Y - 8;

// decorations
float[] flagWorldX = {800, 1600, 2500, 3600, 5000};
String[] flagYards = {"90", "180", "275", "400", "545"};
color[] flagColors = {#E8FF3A, #FF5733, #33C7FF, #FF33A8, #FFFFFF};

float[] treeWorldX = {300, 650, 1100, 1500, 2000, 2700, 3200, 4000, 4700, 5500};
float[] treeHeights = {80, 60, 100, 70, 90, 85, 110, 95, 75, 100};

color skyTop = color(10, 25, 60);
color skyBot = color(60, 120, 200);

// game state
GolfBall activeBall;
int selectedBallType = 1;
float cameraOffset = 0;
float targetCameraOffset = 0;
int resultDisplayTimer = 0;
String notification = "";
int notificationTimer = 0;

// power meter
boolean mouseHeld = false;
float powerMeterValue = 0; // line position
float powerMeterDirection = 1; // direction, -1 for down, 1 for up
float powerMeterSpeed = 0.014; // meter speed

// arraylist of shot records for the history panel
ArrayList<ShotRecord> shotHistory = new ArrayList<ShotRecord>();

void setup() {
  size(900, 600);
  spawnBall();
}

void spawnBall() {
  activeBall = (selectedBallType == 2) ? new DriveBall(TEE_WORLD_X, TEE_Y) : new GolfBall(TEE_WORLD_X, TEE_Y);
  cameraOffset = 0;
  targetCameraOffset = 0;
  powerMeterValue = 0;
  powerMeterDirection = 1;
  powerMeterSpeed = (selectedBallType == 2) ? 0.020 : 0.014;
}

// main game loop
void draw() {
  drawSky();
  cameraOffset += (targetCameraOffset - cameraOffset) * 0.08;

  drawGround();
  drawDistanceMarkers();
  drawTrees();
  drawFlags();
  drawTee();

  // move line up and down while mouse is held
  if (mouseHeld) {
    powerMeterValue += powerMeterDirection * powerMeterSpeed;
    if (powerMeterValue >= 1.0) {
      powerMeterValue = 1.0; powerMeterDirection = -1;
    }
    if (powerMeterValue <= 0.0) {
      powerMeterValue = 0.0; powerMeterDirection = 1;
    }
  }

  activeBall.update();

  // camera follow
  float ballScreenX = activeBall.worldX - cameraOffset;
  if (ballScreenX > width * 0.55)
    targetCameraOffset = activeBall.worldX - width * 0.55;
  targetCameraOffset = max(0, targetCameraOffset);

  // ball just landed
  if (activeBall.justLanded()) {
    float shotYards = (activeBall.worldX - TEE_WORLD_X) / 5.5;
    ShotRecord shotRecord = new ShotRecord(shotYards, activeBall.launchStrength * 100, activeBall.getTypeName());
    shotHistory.add(shotRecord);
    resultDisplayTimer = 240;
  }

  activeBall.drawTrail(cameraOffset);
  activeBall.drawSelf(cameraOffset);

  drawHUD();
  if (!activeBall.inFlight && !activeBall.ballLanded && mouseHeld) drawAimLine();
  if (resultDisplayTimer > 0) { drawResult(); resultDisplayTimer--; }
  if (!activeBall.inFlight && !mouseHeld) drawInstructions();
  if (notificationTimer > 0) { drawNotification(); notificationTimer--; }
  drawShotHistory();
}

// input
void mousePressed() {
  if (!activeBall.inFlight) {
    if (activeBall.ballLanded) spawnBall();
    mouseHeld = true;
    powerMeterValue = 0;
    powerMeterDirection = 1;
    activeBall.clearTrail();
    resultDisplayTimer = 0;
  }
}

void mouseReleased() {
  if (!activeBall.inFlight && mouseHeld) {
    mouseHeld = false;
    activeBall.shoot(mouseX + cameraOffset, mouseY, powerMeterValue);
  }
}

void keyPressed() {
  if (activeBall.inFlight) return;
  if (key == '1') {
    selectedBallType = 1; spawnBall();
    notification = "Standard Ball selected"; notificationTimer = 120;
  } else if (key == '2') {
    selectedBallType = 2; spawnBall();
    notification = "Power Drive Ball selected!"; notificationTimer = 120;
  }
}

float worldToScreen(float worldX) { return worldX - cameraOffset; }

// scene
void drawSky() {
  for (int y = 0; y < height; y++) {
    stroke(lerpColor(skyTop, skyBot, (float)y / height));
    line(0, y, width, y);
  }
  noStroke(); randomSeed(42); fill(255, 180);
  for (int i = 0; i < 60; i++)
    ellipse(random(width), random(GROUND_Y * 0.6), 1.5, 1.5);
}

void drawGround() {
  noStroke(); fill(34, 120, 34);
  rect(0, GROUND_Y, width, height - GROUND_Y);
  fill(25, 95, 25);
  rect(0, GROUND_Y, width, 14);
  fill(80, 180, 80);
  rect(worldToScreen(TEE_WORLD_X - 60), GROUND_Y - 4, 120, 10, 3);
}

void drawTee() {
  float teeScreenX = worldToScreen(TEE_WORLD_X);
  stroke(220, 180, 100); strokeWeight(2);
  line(teeScreenX, TEE_Y, teeScreenX, TEE_Y + 10);
  noStroke(); fill(220, 180, 100);
  ellipse(teeScreenX, TEE_Y, 8, 4);
}

void drawDistanceMarkers() {
  for (int i = 0; i < flagWorldX.length; i++) {
    float screenX = worldToScreen(flagWorldX[i]);
    if (screenX < -20 || screenX > width + 20) continue;
    stroke(255, 255, 255, 60); strokeWeight(1);
    for (int y = (int)GROUND_Y - 2; y > GROUND_Y - 60; y -= 8)
      line(screenX, y, screenX, y - 4);
    noStroke(); fill(255, 255, 255, 80);
    textAlign(CENTER, BOTTOM); textSize(10);
    text(flagYards[i] + "y", screenX, GROUND_Y - 62);
  }
}

void drawFlags() {
  for (int i = 0; i < flagWorldX.length; i++) {
    float screenX = worldToScreen(flagWorldX[i]);
    if (screenX < -30 || screenX > width + 30) continue;
    float flagTopY = GROUND_Y - 70 - (i * 5 % 20);
    stroke(200); strokeWeight(1.5);
    line(screenX, GROUND_Y, screenX, flagTopY);
    noStroke(); fill(flagColors[i]);
    float flagWaveOffset = sin(frameCount * 0.07 + i) * 5;
    beginShape();
    vertex(screenX, flagTopY); vertex(screenX + 22 + flagWaveOffset, flagTopY + 6);
    vertex(screenX + 20 + flagWaveOffset, flagTopY + 16); vertex(screenX, flagTopY + 12);
    endShape(CLOSE);
  }
}

void drawTrees() {
  for (int i = 0; i < treeWorldX.length; i++) {
    float screenX = worldToScreen(treeWorldX[i]);
    if (screenX < -60 || screenX > width + 60) continue;
    float treeHeight = treeHeights[i];
    float groundY = GROUND_Y;
    fill(90, 55, 30); noStroke();
    rect(screenX - 5, groundY - 24, 10, 24, 2);
    fill(20, 90, 20);
    triangle(screenX - treeHeight * 0.5, groundY - 24, screenX + treeHeight * 0.5, groundY - 24, screenX, groundY - 24 - treeHeight);
    fill(30, 110, 30);
    triangle(screenX - treeHeight * 0.4, groundY - 24 - treeHeight * 0.3, screenX + treeHeight * 0.4, groundY - 24 - treeHeight * 0.3, screenX, groundY - 24 - treeHeight * 1.15);
  }
}

void drawAimLine() {
  float mouseWorldX = mouseX + cameraOffset;
  float mouseWorldY = mouseY;
  float aimAngle = atan2(mouseWorldY - activeBall.worldY, mouseWorldX - activeBall.worldX);
  aimAngle = constrain(aimAngle, -PI * 0.90, -0.05);
  float ballScreenX = worldToScreen(activeBall.worldX);
  float aimEndX = ballScreenX + cos(aimAngle) * 120;
  float aimEndY = activeBall.worldY + sin(aimAngle) * 120;
  stroke(255, 255, 100, 160); strokeWeight(1.5);
  for (int i = 0; i < 10; i++) {
    float progressStart = i / 10.0, progressEnd = (i + 0.5) / 10.0;
    line(lerp(ballScreenX, aimEndX, progressStart), lerp(activeBall.worldY, aimEndY, progressStart), lerp(ballScreenX, aimEndX, progressEnd), lerp(activeBall.worldY, aimEndY, progressEnd));
  }
  noStroke(); fill(255, 255, 100);
  pushMatrix(); translate(aimEndX, aimEndY); rotate(aimAngle);
  triangle(8, 0, -4, -4, -4, 4); popMatrix();
}

// HUD
void drawHUD() {
  float meterX = 30, meterY = 30, meterWidth = 18, meterHeight = 180;

  // panel background
  noStroke(); fill(0, 0, 0, 120);
  rect(meterX - 10, meterY - 10, meterWidth + 20, meterHeight + 50, 6);

  // dimmed gradient
  for (int y = 0; y < meterHeight; y++) {
    float progress = 1.0 - (float)y / meterHeight;
    color gradientColor = progress < 0.5
      ? lerpColor(color(50, 220, 50), color(255, 220, 0), progress * 2)
      : lerpColor(color(255, 220, 0), color(255, 50, 50), (progress - 0.5) * 2);
    stroke(gradientColor, 55); strokeWeight(1);
    line(meterX, meterY + y, meterX + meterWidth, meterY + y);
  }

  // full gradient
  if (mouseHeld) {
    for (int y = 0; y < meterHeight; y++) {
      float progress = 1.0 - (float)y / meterHeight;
      color gradientColor = progress < 0.5
        ? lerpColor(color(50, 220, 50), color(255, 220, 0), progress * 2)
        : lerpColor(color(255, 220, 0), color(255, 50, 50), (progress - 0.5) * 2);
      if (progress <= powerMeterValue) { stroke(gradientColor); strokeWeight(1); line(meterX, meterY + y, meterX + meterWidth, meterY + y); }
    }

    // line
    float needleY = meterY + meterHeight * (1.0 - powerMeterValue);
    stroke(255, 255, 255, 90); strokeWeight(6);
    line(meterX - 2, needleY, meterX + meterWidth + 2, needleY);
    stroke(255); strokeWeight(2);
    line(meterX - 2, needleY, meterX + meterWidth + 2, needleY);
  }

  // border
  noFill(); stroke(255, 255, 255, 200); strokeWeight(1.5);
  rect(meterX, meterY, meterWidth, meterHeight, 3);

  // labels
  noStroke(); fill(255); textAlign(CENTER, TOP); textSize(11);
  text("PWR", meterX + meterWidth / 2, meterY + meterHeight + 8);
  if (mouseHeld) {
    fill(255, 220, 80); textSize(12);
    text(nf(powerMeterValue * 100, 0, 0) + "%", meterX + meterWidth / 2, meterY + meterHeight + 24);
  }

  // ball type
  fill(activeBall instanceof DriveBall ? color(255, 80, 80) : color(200, 220, 255));
  textSize(10); text(activeBall.getTypeName(), meterX + meterWidth / 2, meterY + meterHeight + 38);

  // distance readout
  if (activeBall.inFlight || activeBall.ballLanded) {
    float distanceYards = (activeBall.worldX - TEE_WORLD_X) / 5.5;
    noStroke(); fill(0, 0, 0, 120);
    rect(width - 160, 20, 140, 36, 5);
    fill(255, 220, 80); textAlign(RIGHT, CENTER); textSize(22);
    text(nf(distanceYards, 0, 0) + " yds", width - 18, 38);
  }

  // title
  noStroke(); fill(0, 0, 0, 100);
  rect(width / 2 - 90, 10, 180, 30, 5);
  fill(255); textAlign(CENTER, CENTER); textSize(13);
  text("DRIVING RANGE", width / 2, 25);
}

void drawResult() {
  ShotRecord latestShot = shotHistory.get(shotHistory.size() - 1);
  float fadeAlpha = min(resultDisplayTimer, 60) / 60.0 * 255;
  float centerX = width / 2, centerY = height / 2 - 30;
  noStroke(); fill(0, 0, 0, fadeAlpha * 0.7);
  rect(centerX - 160, centerY - 50, 320, 110, 10);
  fill(255, 220, 80, fadeAlpha); textAlign(CENTER, CENTER); textSize(28);
  text(latestShot.label, centerX, centerY - 12);
  fill(255, 255, 255, fadeAlpha); textSize(15);
  text(nf(latestShot.distanceYards, 0, 0) + " yards  |  " + nf(latestShot.powerPercent, 0, 0) + "% power", centerX, centerY + 18);
  fill(180, 220, 255, fadeAlpha); textSize(11);
  text("Ball: " + latestShot.ballTypeName, centerX, centerY + 38);
  if (resultDisplayTimer < 80) {
    fill(200, 200, 200, (80 - resultDisplayTimer) / 80.0 * 200); textSize(12);
    text("Click to hit again  |  1=Standard  2=Power Drive", centerX, centerY + 62);
  }
}

void drawShotHistory() {
  if (shotHistory.isEmpty()) return;
  float panelX = width - 165, panelY = 70, panelWidth = 155, lineHeight = 16;
  int visibleShots = min(shotHistory.size(), 6);
  noStroke(); fill(0, 0, 0, 110);
  rect(panelX - 4, panelY - 4, panelWidth + 8, visibleShots * lineHeight + 22, 5);
  fill(180, 220, 255); textAlign(LEFT, TOP); textSize(10);
  text("SHOT HISTORY (" + shotHistory.size() + ")", panelX, panelY);
  panelY += 16;
  for (int i = shotHistory.size() - 1; i >= shotHistory.size() - visibleShots; i--) {
    ShotRecord shotRecord = shotHistory.get(i);
    color rowColor = shotRecord.ballTypeName.equals("Power Drive") ? color(255, 140, 140) : color(220, 220, 220);
    fill(rowColor);
    text("#" + (i + 1) + "  " + nf(shotRecord.distanceYards, 0, 0) + "y  " + shotRecord.label, panelX, panelY);
    panelY += lineHeight;
  }
}

void drawInstructions() {
  if (activeBall.ballLanded) return;
  noStroke(); fill(255, 255, 255, 160); textAlign(LEFT, CENTER); textSize(12);
  text("Aim with mouse  |  Hold to charge  |  Release to swing  |  1/2 = ball type", 70, height-25);
}

void drawNotification() {
  float alpha = min(notificationTimer, 30) / 30.0 * 220;
  noStroke(); fill(0, 0, 0, alpha * 0.7);
  rect(width / 2 - 140, height - 60, 280, 28, 5);
  fill(255, 255, 100, alpha); textAlign(CENTER, CENTER); textSize(13);
  text(notification, width / 2, height - 46);
}
