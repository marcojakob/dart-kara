part of kara;

/**
 * Ein Pilz kann von Kara gestossen werden falls nichts hinter dem Pilz steht.
 */
class Mushroom extends Actor {

  /// Determines whether the mushroom is on target (that means on a Leaf).
  bool onTarget;

  /// Constructor.
  Mushroom(World world, int x, int y, {this.onTarget: false}) {
    this.world = world;
    this.x = x;
    this.y = y;
  }

  @override
  String get imageName {
    if (onTarget) {
      // Mushroom is on a leaf.
      return 'mushroom-on-target';
    } else {
      return 'mushroom';
    }
  }

  @override
  void act() {
  }
}
