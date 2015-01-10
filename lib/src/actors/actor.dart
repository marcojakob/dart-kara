part of kara;

const int directionRight = 0;
const int directionDown = 90;
const int directionLeft = 180;
const int directionUp = 270;

/// Superclass for all [Actor]s.
abstract class Actor {

  /// A reference to the world.
  World world;
  
  /// The horizontal position.
  int x = 0;
  
  /// The vertical position.
  int y = 0;
  
  /// The name of the actor's current image.
  String get imageName;
  
  Bitmap _bitmap;
  
  /// Visual representation of this [Actor].
  /// 
  /// Note: The position of the [Actor] and its [Bitmap] may not be in 
  /// sync because the visual moves and turns are delayed.
  Bitmap get bitmap {
    if (_bitmap == null) {
      // Create the bitmap.
      var coords = World.cellToPixel(x, y);
      _bitmap = new Bitmap(world.resourceManager.getBitmapData(imageName));
      _bitmap
          ..x = coords.x
          ..y = coords.y
          ..pivotX = _bitmap.width / 2
          ..pivotY = _bitmap.height / 2;
    }
    
    return _bitmap;
  }
  
  /// The act method that gets called periodically.
  void act();
  
  /// Adds the bitmap of this actor to the world.
  void _addToWorld() {
    world._getLayer(this).addChild(bitmap);
  }
  
  /// Removes the bitmap of this actor from the world.
  void _removeFromWorld() {
    world._getLayer(this).removeChild(bitmap);
  }
  
  /// Moves the actor in the specified [direction].
  /// 
  /// If the actor moves over the world's edge it will appear on the opposite 
  /// side.
  void _move(int direction) {
    switch (direction) {
      case directionRight:
        x = (x + 1) % world.scenario.width;
        break;
      case directionDown:
        y = (y + 1) % world.scenario.height;
        break;
      case directionLeft:
        x = (x - 1) % world.scenario.width;
        break;
      case directionUp:
        y = (y - 1) % world.scenario.height;
        break;
    }
  }
    
  /// Creates a move animation from [currentPoint] to the [targetPoint] with
  /// the specified [speed]. 
  Animatable _moveAnimation(Point currentPoint, Point targetPoint, 
                                  int direction, Duration speed) {

    Point moveOutPoint; // The point we move to if screen is left.
    Point moveInPoint; // The point we move in from if screen was left.
    
    // Test if the animation goes out of bounds and must thus appear on the 
    // other side.
    if (direction == directionRight && targetPoint.x <= currentPoint.x) {
      // Crossed the right border.
      moveOutPoint = new Point(currentPoint.x + 1, currentPoint.y);
      moveInPoint = new Point(targetPoint.x - 1, targetPoint.y);     
    } else if (direction == directionDown && targetPoint.y <= currentPoint.y) {
      // Crossed the bottom border.
      moveOutPoint = new Point(currentPoint.x, currentPoint.y + 1);
      moveInPoint = new Point(targetPoint.x, targetPoint.y - 1);     
    } else if (direction == directionLeft && targetPoint.x >= currentPoint.x) {
      // Crossed the left border.
      moveOutPoint = new Point(currentPoint.x - 1, currentPoint.y);
      moveInPoint = new Point(targetPoint.x + 1, targetPoint.y);     
    } else if (direction == directionUp && targetPoint.y >= currentPoint.y) {
      // Crossed the bottom border.
      moveOutPoint = new Point(currentPoint.x, currentPoint.y - 1);
      moveInPoint = new Point(targetPoint.x, targetPoint.y + 1);     
    }
    
    if (moveOutPoint != null && moveInPoint != null) {
      // Must create multiple animations because we're out of bounds and appear 
      // again on other side.
      AnimationChain animChain = new AnimationChain();
      
      Point currentPixel = World.cellToPixel(currentPoint.x, currentPoint.y);
      
      // Create a clone to animate out.
      var bitmapClone = new Bitmap(bitmap.bitmapData)
          ..x = currentPixel.x
          ..y = currentPixel.y
          ..pivotX = bitmap.width / 2
          ..pivotY = bitmap.height / 2;

      if (this is Kara) {
        bitmapClone.rotation = (this as Kara).directionRadian;
      }
      
      // Add the clone.
      animChain.add(new DelayedCall(() {
        world._getLayer(this).addChild(bitmapClone);
      }, 0));
      
      
      Point moveInPixel = World.cellToPixel(moveInPoint.x, moveInPoint.y);
      animChain.add(new DelayedCall(() {
        bitmap.x = moveInPixel.x;
        bitmap.y = moveInPixel.y;
      }, 0));
      
      AnimationGroup animGroup = new AnimationGroup();      
      animChain.add(animGroup);
      
      // Animate clone to the point that is out of bounds.
      Point moveOutPixel = World.cellToPixel(moveOutPoint.x, moveOutPoint.y);
      animGroup.add(new Tween(bitmapClone, speed.inMilliseconds / 1000, TransitionFunction.easeInOutQuadratic)
          ..animate.x.to(moveOutPixel.x)
          ..animate.y.to(moveOutPixel.y));
      
      // Animate original to the target point.
      Point targetPixel = World.cellToPixel(targetPoint.x, targetPoint.y);
      animGroup.add(new Tween(bitmap, speed.inMilliseconds / 1000, TransitionFunction.easeInOutQuadratic)
          ..animate.x.to(targetPixel.x)
          ..animate.y.to(targetPixel.y));
      
      
      // Remove clone.
      animChain.add(new DelayedCall(() {
        world._getLayer(this).removeChild(bitmapClone);
      }, 0));
      
      return animChain;
    } else {
      // Animation to the target point.
      Point targetPixel = World.cellToPixel(targetPoint.x, targetPoint.y);
      return new Tween(bitmap, speed.inMilliseconds / 1000, TransitionFunction.easeInOutQuadratic)
          ..animate.x.to(targetPixel.x)
          ..animate.y.to(targetPixel.y);
    }
  }
  
  /// Creates a turn animation that turns by [deltaValue], in radians.
  Animatable _turnByAnimation(num deltaValue, Duration speed) {
    Tween anim = new Tween(bitmap, speed.inMilliseconds / 1000, TransitionFunction.easeInOutQuadratic)
        ..animate.rotation.by(deltaValue);
    
    return anim;
  }
  
  /// Creates an update image animation.
  Animatable _updateImageAnimation(String newImageName, Duration speed) {
    return new DelayedCall(() {
      bitmap.bitmapData = world.resourceManager.getBitmapData(newImageName);
    }, speed.inMilliseconds / 1500);
  }
}