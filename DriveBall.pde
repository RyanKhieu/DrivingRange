class DriveBall extends GolfBall {

  DriveBall(float startWorldX, float startWorldY) {
    super(startWorldX, startWorldY); // inherit everything from super

    // physics changes
    maxLaunchSpeed = 52; // higher max speed for more distance
    gravity = 0.28; // more floaty
    airFriction = 0.997; // less air resistance
    bounceDamping = 0.20; // less bounce on landing
    rollFriction = 0.75;
  }

  // red trail
  color trailColor(float progress) {
    return color(255, lerp(50, 160, progress), 20, progress * 200);
  }

  // red ball with D text
  void drawSelf(float cameraOffset) {
    float screenX = worldX - cameraOffset;

    // shadow
    noStroke(); fill(0, 0, 0, 70);
    ellipse(screenX, GROUND_Y + 2, 16, 5);

    // ball body 
    fill(255, 220, 210); stroke(200, 80, 80); strokeWeight(1.5);
    ellipse(screenX, worldY, 15, 15);

    // D letter
    noStroke(); fill(200, 60, 60);
    textAlign(CENTER, CENTER); textSize(7);
    text("D", screenX, worldY + 1);
  }

  // change label
  String getTypeName() { return "Power Drive"; }
}
