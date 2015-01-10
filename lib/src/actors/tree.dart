part of kara;

/**
 * Ein Baum ist ein Hindernis fuer Kara. Kara kann weder durch Baeume hindurch
 * gehen noch kann er sie schieben.
 */
class Tree extends Actor {
  
  /// Constructor.
  Tree(World world, int x, int y) {
    this.world = world;
    this.x = x;
    this.y = y;
  }
  
  @override
  String get imageName => 'tree';

  @override
  void act() {
  }
}
