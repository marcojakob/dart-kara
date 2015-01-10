part of kara;

/// Diese Klasse ist die Oberklasse fuer alle Karas und enthaelt die
/// Grundfunktionen von Kara. Programme sollten nur in den Unterklassen wie
/// MyKara geschrieben werden.
abstract class Kara extends Actor {

  /// Kara macht einen Schritt in die aktuelle Richtung.
  void move() {
    // Check for a tree.
    if (treeFront()) {
      world.queueAction((spd) {
        throw new KaraException(messages.cantMoveBecauseOfTree());
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
          animGroup.add(mushroomFront._bitmap.moveAnimation(mushroomStart, mushroomEnd,
                                                     karaDir, spd));
          animGroup.add(mushroomFront._bitmap.delayedUpdateImage(mushroomImage, spd));
          animGroup.add(_bitmap.moveAnimation(karaStart, karaEnd, karaDir, spd));

          world.juggler.add(animGroup);
        });

      } else {
        // Could not push the mushroom.
        world.queueAction((spd) {
          throw new KaraException(messages.cantMoveBecauseOfMushroom());
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
        world.juggler.add(_bitmap.moveAnimation(karaStart, karaEnd, dir, spd));
      });
    }
  }

  /// Kara turns left by 90 degrees.
  void turnLeft() {
    direction = (direction - 90) % 360;

    world.queueAction((spd) {
      Animatable anim = _bitmap.turnByAnimation(-math.PI / 2, spd);
      world.juggler.add(anim);
    });
  }

  /// Kara turns right by 90 degrees.
  void turnRight() {
    direction = (direction + 90) % 360;

    world.queueAction((spd) {
      world.juggler.add(_bitmap.turnByAnimation(math.PI / 2, spd));
    });
  }

  /// Kara puts down a leaf.
  void putLeaf() {
    if (!onLeaf()) {
      Leaf leaf = new Leaf(world, x, y);
      world.actors.add(leaf);

      world.queueAction((spd) {
        leaf._addToWorld();
      });
    } else {
      world.queueAction((spd) {
        throw new KaraException(messages.cantPutLeaf());
      });
      stop();
    }
  }

  /// Kara picks up a leaf.
  void removeLeaf() {
    Leaf leaf = world.getActorsAt(x, y).firstWhere((Actor a) => a is Leaf, orElse: () => null);
    if (leaf != null) {
      world.actors.remove(leaf);

      world.queueAction((spd) {
        leaf._removeFromWorld();
      });
    } else {
      world.queueAction((spd) {
        throw new KaraException(messages.cantRemoveLeaf());
      });
      stop();
    }
  }

  /// Kara checks if he stands on a leaf.
  bool onLeaf() {
    return world.getActorsAt(x, y).any((Actor a) => a is Leaf);
  }

  /// Kara checks if there is a tree in front of him.
  bool treeFront() {
    return world.getActorsInFront(x, y, direction).any((Actor a) => a is Tree);
  }

  /// Kara checks if there is a tree on his left side.
  bool treeLeft() {
    return world.getActorsInFront(x, y, (direction - 90) % 360).any((Actor a) => a is Tree);
  }

  /// Kara checks if there is a tree on his right side.
  bool treeRight() {
    return world.getActorsInFront(x, y, (direction + 90) % 360).any((Actor a) => a is Tree);
  }

  /// Kara checks if there is a mushroom in front of him.
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
  String get imageName => 'kara';
}
