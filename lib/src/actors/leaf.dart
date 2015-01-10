part of kara;

/**
 * Ein Blatt kann von Kara gelegt und wieder aufgelesen werden.
 */
class Leaf extends Actor {
  
  /// Constructor.
  Leaf(World world, int x, int y) {
    this.world = world;
    this.x = x;
    this.y = y;
  }
  
  @override
  String get imageName => 'leaf';

  @override
  void act() {
  }

}
