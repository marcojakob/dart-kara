part of kara;

/// A [Scenario] contains information about the positions of the actors in the
/// world. A [Scenario] is immutable, i.e. after initialization it should not be
/// changed. An immutable [Scenario] is easier to work with because we can be sure
/// that there will not be any side-effects if we make changes to any actors. And
/// we can always restore the initial [Scenario].
///
/// The actor positions are described with the following signs:
/// * Kara: @
/// * Tree: #
/// * Leaf: .
/// * Mushroom: $
/// * Mushroom on Leaf: *
/// * Kara on Leaf: +
/// * Empty Field: Space
class Scenario {
  static const String undefined = '?';
  static const String empty = ' ';
  static const String kara = '@';
  static const String tree = '#';
  static const String leaf = '.';
  static const String mushroom = r'$'; // r means raw String (dollar sign is treated as a normal String)
  static const String mushroomLeaf = '*'; // Mushroom on a leaf
  static const String karaLeaf = '+'; // Kara on a leaf

  /// The title of the [Scenario].
  final String title;

  /// The world [width] in number of cells.
  final int width;

  /// The world [height] in number of rows.
  final int height;

  /// a multi-line String with actor signs.
  final String actors;

  /// The direction Kara is facing.
  final int karaDirection;

  /// Creates a [Scenario] with specified [title], [width] and [height].
  ///
  /// [karaDirection] is the initial direction Kara is facing.
  ///
  /// [actors] is a multiline String of actor positions in the world.
  /// See [Scenario] class description for a list of possible actor types.
  ///
  /// [actors] is a multi-line String with actor signs. See [Scenario] class
  /// description for a list of possible actor types.
  Scenario({this.title: 'untitled', this.width: 10, this.height: 10,
    this.karaDirection: directionRight, this.actors: '@'});

  /// Builds a list of [Actor]s according to this [Scenario].
  ///
  /// [kara] is the instance used for Kara.
  List<Actor> build(World world, Kara kara) {
    // The result.
    List<Actor> actorList = new List<Actor>();

    // Actor positions: Each list entry is a line (y-position) and the position
    // of the character in the String is the column (x-position).
    List<String> actorPositions = actors.split('\n');

    bool karaAdded = false;

    for (int y = 0; y < actorPositions.length && y < height; y++) {
      for (int x = 0; x < actorPositions[y].length && x < width; x++) {
        switch (actorPositions[y][x]) {
          case Scenario.kara:
            // Only add first occurrence of Kara.
            if (!karaAdded) {
              kara
                  ..x = x
                  ..y = y
                  ..direction = karaDirection;
              actorList.add(_adjustKara(world, kara, x, y, karaDirection));
              karaAdded = true;
            }
            break;
          case Scenario.tree:
            actorList.add(new Tree(world, x, y));
            break;
          case Scenario.leaf:
            actorList.add(new Leaf(world, x, y));
            break;
          case Scenario.mushroom:
            actorList.add(new Mushroom(world, x, y));
            break;
          case Scenario.mushroomLeaf:
            actorList.add(new Mushroom(world, x, y, onTarget: true));
            actorList.add(new Leaf(world, x, y));
            break;
          case Scenario.karaLeaf:
            actorList.add(_adjustKara(world, kara, x, y, karaDirection));
            actorList.add(new Leaf(world, x, y));
            break;
        }
      }
    }

    return actorList;
  }

  /// Helper method to adjust Kara to the provided values.
  Kara _adjustKara(World world, Kara kara, int x, int y, int direction) {
    return kara
        ..world = world
        ..x = x
        ..y = y
        ..direction = direction;
  }
}