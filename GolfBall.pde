class GolfBall {

  // physics
  float worldX, worldY; // position
  float velocityX, velocityY;
  boolean inFlight = false;
  boolean ballLanded = false;
  boolean landedThisFrame = false;
  float launchStrength = 0; // 0-1, for shot record

  // trail
  ArrayList<float[]> trailPoints = new ArrayList<float[]>();

  // physics parameters
  float gravity = 0.35;
  float airFriction = 0.995;
  float bounceDamping = 0.25;
  float rollFriction = 0.80;
  float maxLaunchSpeed = 38;

  // constructor
  GolfBall(float startX, float startY) {
    worldX = startX;
    worldY = startY;
  }

  // called every frame
  void update() {
    landedThisFrame = false;

    if (worldX < 0) {
      worldX = 0;
      velocityX *= -bounceDamping;
    }

    if (!inFlight) return;

    velocityY += gravity;
    velocityX *= airFriction;
    velocityY *= airFriction;
    worldX += velocityX;
    worldY += velocityY;

    if (frameCount % 3 == 0)
      trailPoints.add(new float[]{worldX, worldY});

    // ground collision
    if (worldY >= GROUND_Y) {
      worldY = GROUND_Y;
      velocityY *= -bounceDamping;
      velocityX *= rollFriction;

      if (abs(velocityX) < 0.4 && abs(velocityY) < 0.4) {
        inFlight = false;
        ballLanded = true;
        landedThisFrame = true;
      }
    }
  }

  // returns true on the frame the ball stops
  boolean justLanded() { return landedThisFrame; }

  // launch the ball
  void shoot(float aimWorldX, float aimY, float power) {
    launchStrength = power;
    float deltaX = aimWorldX - worldX;
    float deltaY = aimY - worldY;
    float aimAngle = atan2(deltaY, deltaX);
    aimAngle = constrain(aimAngle, -PI * 0.90, -0.05);
    float launchSpeed = power * maxLaunchSpeed;
    velocityX = cos(aimAngle) * launchSpeed;
    velocityY = sin(aimAngle) * launchSpeed;
    inFlight = true;
  }

  void clearTrail() { trailPoints.clear(); }

  // draw the trail
  void drawTrail(float cameraOffset) {
    for (int i = 1; i < trailPoints.size(); i++) {
      float[] previousPoint = trailPoints.get(i - 1), currentPoint = trailPoints.get(i);
      float progress = (float)i / trailPoints.size();
      stroke(trailColor(progress));
      strokeWeight(lerp(0.5, 2.5, progress));
      line(previousPoint[0] - cameraOffset, previousPoint[1], currentPoint[0] - cameraOffset, currentPoint[1]);
    }
    noStroke();
  }

  // trail color
  color trailColor(float progress) {
    return color(255, 220, 80, progress * 180);
  }

  // draw ball
  void drawSelf(float cameraOffset) {
    float screenX = worldX - cameraOffset;

    // shadow
    noStroke(); fill(0, 0, 0, 60);
    ellipse(screenX, GROUND_Y + 2, 14, 4);

    // ball body
    fill(255); stroke(200); strokeWeight(1);
    ellipse(screenX, worldY, 14, 14);

    // dimples
    noStroke(); fill(220);
    ellipse(screenX - 2, worldY - 2, 3, 3);
    ellipse(screenX + 3, worldY + 1, 2, 2);
  }

  // type name
  String getTypeName() { return "Standard"; }

  // shot label based on distance
  String computeLabel(float distanceYards) {
    if (distanceYards < 50)
      return "Whiff!";
    if (distanceYards < 100)
      return "Chip Shot";
    if (distanceYards < 180)
      return "Iron";
    if (distanceYards < 260)
      return "Mid Drive";
    if (distanceYards < 330)
      return "Long Drive!";

    return "MONSTER DRIVE!!";
  }
}
