part of kara;

/// Diese Klasse ist die Oberklasse fuer alle Karas und enthaelt die
/// Grundfunktionen von Kara. Programme sollten nur in den Unterklassen wie
/// MyKara geschrieben werden.
abstract class Kara extends Actor {
  
  /// The direction [Kara] is currently facing.
  int direction;

  /// Kara macht einen Schritt in die aktuelle Richtung.
  void move() {
    // Check for a tree.
    if (treeFront()) {
      world.queueAction((spd) {
        throw new KaraException('Kara kann sich nicht bewegen wegen einem Baum!');
      });
      stop();
    }
    
    // Check for a mushroom.
    Mushroom mushroomFront = world.getActorsInFront(x, y, direction)
        .firstWhere((Actor a) => a is Mushroom, orElse: () => null);
    
    if (mushroomFront != null) {
      // Check if the mushroom can be pushed to the next field.
      if (!world.getActorsInFront(x, y, direction, 2)
          .any((Actor a) => a is Tree || a is Mushroom)) {
        
        Point mushroomStart = new Point(mushroomFront.x, mushroomFront.y);
        Point karaStart = new Point(x, y);
        
        // Push the mushroom and move Kara.
        mushroomFront._move(direction);
        _move(direction);
        
        // Check for a leaf under the mushroom.
        mushroomFront.onTarget = world.getActorsAt(mushroomFront.x, mushroomFront.y)
            .any((actor) => actor is Leaf);
        
        Point mushroomEnd = new Point(mushroomFront.x, mushroomFront.y);
        Point karaEnd = new Point(x, y);
        
        // Save the current mushroom image name and the kara direction.
        String mushroomImage = mushroomFront.imageName;
        int karaDir = direction;
        
        world.queueAction((spd) {
          AnimationGroup animGroup = new AnimationGroup();
          animGroup.add(mushroomFront._moveAnimation(mushroomStart, mushroomEnd, 
                                                     karaDir, spd));
          animGroup.add(mushroomFront._updateImageAnimation(mushroomImage, spd));
          animGroup.add(_moveAnimation(karaStart, karaEnd, karaDir, spd));
          
          world.juggler.add(animGroup);
        });
        
      } else {
        // Could not push the mushroom.
        world.queueAction((spd) {
          throw new KaraException('Kara kann sich nicht bewegen, da er den Pilz nicht schieben kann!');
        });
        stop();
      }
    } else {
      // Nothing in the way, Kara can move.
      Point karaStart = new Point(x, y);
      _move(direction);
      Point karaEnd = new Point(x, y);
      int dir = direction;
      
      world.queueAction((spd) {
        world.juggler.add(_moveAnimation(karaStart, karaEnd, dir, spd));
      });
    }
  }
  
  /// Kara dreht sich um 90° nach links.
  void turnLeft() {
    direction = (direction - 90) % 360;
    
    world.queueAction((spd) {
      Animatable anim = _turnByAnimation(-math.PI / 2, spd);
      world.juggler.add(anim);
    });
  }
  
  /// Kara dreht sich um 90° nach rechts.
  void turnRight() {
    direction = (direction + 90) % 360;
    
    world.queueAction((spd) {
      world.juggler.add(_turnByAnimation(math.PI / 2, spd));
    });
  }
  
  /// Kara legt ein neues Kleeblatt an die Position, auf der er sich befindet.
  void putLeaf() {
    if (!onLeaf()) {
      Leaf leaf = new Leaf(world, x, y);
      world.actors.add(leaf);
      
      world.queueAction((spd) {
        leaf._addToWorld();
      });
    } else {
      world.queueAction((spd) {
        throw new KaraException('Kara kann kein Kleeblatt auf ein Feld legen, auf dem schon eines ist!');
      });
      stop();
    }
  }
  
  /// Kara entfernt ein unter ihm liegendes Kleeblatt.
  void removeLeaf() {
    Leaf leaf = world.getActorsAt(x, y).firstWhere((Actor a) => a is Leaf, orElse: () => null);
    if (leaf != null) {
      world.actors.remove(leaf);
      
      world.queueAction((spd) {
        leaf._removeFromWorld();
      });
    } else {
      world.queueAction((spd) {
        throw new KaraException('Kara kann hier kein Blatt auflesen!');
      });
      stop();
    }
  }
  
  /// Kara schaut nach, ob er sich auf einem Kleeblatt befindet. Gibt true 
  /// zurueck, wenn er auf einem Kleeblatt ist, sonst false.
  bool onLeaf() {
    return world.getActorsAt(x, y).any((Actor a) => a is Leaf);
  }
  
  /// Kara schaut nach, ob sich ein Baum vor ihm befindet. Gibt true zurueck,
  /// wenn er vor einem Baum steht, sonst false.
  bool treeFront() {
    return world.getActorsInFront(x, y, direction).any((Actor a) => a is Tree);
  }
  
  /// Kara schaut nach, ob sich ein Baum links von ihm befindet. Gibt true 
  /// zurueck, wenn links von ihm ein Baum steht, sonst false.
  bool treeLeft() {
    return world.getActorsInFront(x, y, (direction - 90) % 360).any((Actor a) => a is Tree);
  }
  
  /// Kara schaut nach, ob sich ein Baum rechts von ihm befindet. Gibt true 
  /// zurueck, wenn rechts von ihm ein Baum steht, sonst false.
  bool treeRight() {
    return world.getActorsInFront(x, y, (direction + 90) % 360).any((Actor a) => a is Tree);
  }
  
  /// Kara schaut nach, ob er einen Pilz vor sich hat. Gibt true zurueck, wenn 
  /// vor ihm ein Pilz steht, sonst false.
  bool mushroomFront() {
    return world.getActorsInFront(x, y, direction).any((Actor a) => a is Mushroom);
  }
  
  /// Stops the execution.
  void stop() {
    // We throw an exception here because it is the only way to immediately
    // leave an executing method.
    throw new StopException();
  }
  
  @override
  String get imageName => 'kara_right';
  
  num get directionRadian => direction * math.PI / 180;
}
