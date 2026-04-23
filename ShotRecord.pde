class ShotRecord {

  float distanceYards; // distance in yards
  float powerPercent; // power percentage used (0-100)
  String ballTypeName; // ball type
  String label; // hit label

  ShotRecord(float distanceYards, float powerPercent, String ballTypeName) {
    this.distanceYards = distanceYards;
    this.powerPercent = powerPercent;
    this.ballTypeName = ballTypeName;

    // compute the label
    if (distanceYards < 50)
      label = "Whiff!";
    else if (distanceYards < 100)
      label = "Chip Shot";
    else if (distanceYards < 180)
      label = "Iron";
    else if (distanceYards < 260)
      label = "Mid Drive";
    else if (distanceYards < 330)
      label = "Long Drive!";
    else
      label = "MONSTER DRIVE!!";
  }

  // summary string
  String toString() {
    return ballTypeName + " | " + nf(distanceYards, 0, 0) + "y | " + label + " | " + nf(powerPercent, 0, 0) + "%";
  }
}
