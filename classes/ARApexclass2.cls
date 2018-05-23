//AR apex class 2

public class ARApexclass2{
  // Attributes usually come first!
  String  name;
  Integer protonTorpedoes;
  Integer deathStarsDestroyed;
  Decimal powerRemaining;

  User    pilot;
  Account manufacturer;


  // Constructor(s) are next
  public ARApexclass2(String nickname, User myUser) {
    name                = nickname;  
    protonTorpedoes     = 2;
    deathStarsDestroyed = 0;
    powerRemaining      = 1.00;
    pilot               = myUser;
  }

  // Finally comes the methods
  public void shootLasers(Integer numberOfShots) {
    for (Integer i = 0; i < numberOfShots; i++) {
      System.debug('PEW!');
    }
  }

  public void fireProtonTorpedo() {
    if (protonTorpedoes > 0) {
      System.debug('KABOOM!!!');
      protonTorpedoes--;  
      deathStarsDestroyed++;
    }
  } 

  public Boolean initiateHyperdrive() {
    Boolean isSuccess = false;    
    if (powerRemaining > 0.10) {
      System.debug('Zoom zoom, WEEE!');
      powerRemaining = powerRemaining - 0.10;
      isSuccess = true;
    }
    return isSuccess;
  }
}