part of kara;

/// This class creates a world for Kara and manages all other actors.
class World extends Sprite {

  /// The maximum number of calls to Kara's action methods that are allowed
  /// during one act() cycle.
  static const int maxActActions = 100;

  /// The scenario of this world.
  final Scenario scenario;

  /// Instance of [Kara] that contains the Kara behavior.
  Kara kara;

  /// The current speed.
  Duration speed;

  /// A list of all actors except Kara (leafs, mushrooms and trees).
  List<Actor> actors;

  /// A Queue of Kara actions waiting to be executed.
  final Queue<KaraAction> _actionQueue = new Queue();

  /// The layer for [Kara].
  Sprite _karaLayer;

  /// The layer for [Leaf]s.
  Sprite _leafsLayer;

  /// The layer for [Muhsroom]s.
  Sprite _mushroomsLayer;

  /// The layer for [Tree]s.
  Sprite _treesLayer;

  /// The subscription to enter frame events.
  StreamSubscription _enterFrameSub;


  // StageXL references.
  Stage stage;
  RenderLoop renderLoop;
  Juggler juggler;
  ResourceManager resourceManager;

  /// Creates a new World with the specified [scenario] and [kara].
  ///
  /// [speed] defines the initial speed.
  World(this.scenario, this.kara, this.speed) {
    // Init the scenario title.
    _initTitle();

    // Init the stage.
    _initStage();

    // Init the speed slider.
    _initSpeedSlider();

    // Init actors.
    actors = scenario.build(this, kara);

    // Load assets.
    _loadAssets().then((_) {

      stage.addChild(this);

      // Mask the border of the world so that actors leaving the edge are not
      // visible.
      mask = new Mask.rectangle(0, 0, widthInPixels, heightInPixels);

      // Draw the background cells.
      _drawCells();

      // Init the layers.
      _karaLayer = new Sprite();
      _leafsLayer = new Sprite();
      _mushroomsLayer = new Sprite();
      _treesLayer = new Sprite();

      // Add the layers, leafs at the bottom, kara on top, etc.
      addChild(_leafsLayer);
      addChild(_mushroomsLayer);
      addChild(_treesLayer);
      addChild(_karaLayer);

      // Add actors.
      actors.forEach((actor) => actor._addToWorld());

      // Start listening to enter frame events of the event loop.
      _enterFrameSub = onEnterFrame.listen((_) => _checkActionQueue());
    });
  }

  /// Initializes the scenario title.
  void _initTitle() {
    // Create the title element and add it to the html body element.
    html.Element titleElement = new html.Element.tag('h2')
      ..id = 'title'
      ..text = scenario.title;
    html.document.body.children.add(titleElement);
  }

  /// Initialize the [stage], [renderLoop], [juggler], and [resourceManager].
  void _initStage() {
    // Create the canvas element and add it to the html body element.
    html.CanvasElement stageCanvas = new html.CanvasElement()
      ..id = 'stage';
    html.document.body.children.add(stageCanvas);

    // Init the Stage.
    stage = new Stage(stageCanvas,
        width: widthInPixels,
        height: heightInPixels,
        webGL: true);

    renderLoop = new RenderLoop()
        ..addStage(stage);
    juggler = renderLoop.juggler;
    resourceManager = new ResourceManager();
  }

  /// Loads all assets.
  /// Assets are finished loading when the returned [Future] completes.
  Future _loadAssets() {
    resourceManager
        ..addBitmapData('field', '$assetDir/images/field.png')
        ..addBitmapData('border-top', '$assetDir/images/border-top.png')
        ..addBitmapData('border-left', '$assetDir/images/border-left.png')
        ..addBitmapData('border-corner', '$assetDir/images/border-corner.png')
        ..addBitmapData('kara', '$assetDir/images/kara.png')
        ..addBitmapData('leaf', '$assetDir/images/leaf.png')
        ..addBitmapData('mushroom', '$assetDir/images/mushroom.png')
        ..addBitmapData('mushroom-on-target', '$assetDir/images/mushroom-on-target.png')
        ..addBitmapData('tree', '$assetDir/images/tree.png');

    return resourceManager.load();
  }

  /// Draws the worlds background.
  void _drawCells() {

    // Draw the cells.
    for (int y = 0; y < scenario.height; y++) {
      for (int x = 0; x < scenario.width; x++) {
        var coords = cellToPixel(x, y);
        var field = new Bitmap(resourceManager.getBitmapData('field'));
        field
            ..x = coords.x
            ..y = coords.y
            ..pivotX = field.width / 2
            ..pivotY = field.height / 2;
        addChild(field);
      }
    }

    // Draw the left border.
    for (int y = 0; y < scenario.height; y++) {
      var leftBorder = new Bitmap(resourceManager.getBitmapData('border-left'));
      leftBorder
          ..x = 0
          ..y = y * cellSize + cellBorderSize;
      addChild(leftBorder);
    }

    // Draw the top border.
    for (int x = 0; x < scenario.width; x++) {
      var topBorder = new Bitmap(resourceManager.getBitmapData('border-top'));
      topBorder
          ..x = x * cellSize + cellBorderSize
          ..y = 0;
      addChild(topBorder);
    }

    // Draw the corner.
    var corner = new Bitmap(resourceManager.getBitmapData('border-corner'));
    corner
        ..x = 0
        ..y = 0;
    addChild(corner);
  }

  /// Returns the layer for the actor type.
  Sprite _getLayer(Actor actor) {
    if (actor is Leaf) {
      return _leafsLayer;
    } else if (actor is Mushroom) {
      return _mushroomsLayer;
    } else if (actor is Tree) {
      return _treesLayer;
    } else {
      return _karaLayer;
    }
  }

  /// Initializes the slider to change the speed.
  void _initSpeedSlider() {
    html.InputElement slider = new html.InputElement(type: 'range');
    slider..id = 'speed-slider'
        ..min = '0'
        ..max = '100'
        ..value = '${100 - _logValueToSlider(speed.inMilliseconds)}'
        ..step = '1'
        ..onChange.listen((_) {
          int sliderValue = 100 - math.max(0, math.min(100, int.parse(slider.value)));
          int ms = _logSliderToValue(sliderValue);

          // Set the new speed.
          speed = new Duration(milliseconds: ms);
        });

    html.document.body.children.add(slider);
  }

  /// Converts the [sliderValue] to a speed value in milliseconds.
  int _logSliderToValue(int sliderValue) {
    int minSlider = 0;
    int maxSlider = 100;

    double minValue = math.log(10);
    double maxValue = math.log(1500);

    // Calculate adjustment factor.
    double scale = (maxValue - minValue) / (maxSlider - minSlider);

    return math.exp(minValue + scale * (sliderValue - minSlider)).round();
  }

  /// Converts the speed [value] to a slider value.
  int _logValueToSlider(int value) {
    int minSlider = 0;
    int maxSlider = 100;

    double minValue = math.log(10);
    double maxValue = math.log(1500);

    // Calculate adjustment factor.
    double scale = (maxValue - minValue) / (maxSlider - minSlider);

    return ((math.log(value) - minValue) / scale + minSlider).round();
  }

  /// Translates a cell coordinate into pixel. This will return the coordinate
  /// of the center of the cell.
  static Point cellToPixel(num x, num y) {
    return new Point(
        x * cellSize + (cellSize / 2) + cellBorderSize,
        y * cellSize + (cellSize / 2) + cellBorderSize);
  }

  /// Returns the world's width in pixels.
  int get widthInPixels => scenario.width * cellSize + cellBorderSize;

  /// Returns the world's height in pixels.
  int get heightInPixels => scenario.height * cellSize + cellBorderSize;

  /// The time when the next action may be executed, in milliseconds.
  num _nextActionTime = 0;

  /// Checks the action queue if there are actions to be exectued. If there are
  /// actions, one action is executed and removed from the queue.
  void _checkActionQueue() {
    if (_actionQueue.isNotEmpty) {
      // Get the current time in milliseconds.
      num currentTime = juggler.elapsedTime * 1000;

      if (currentTime > _nextActionTime) {
        _nextActionTime = currentTime + speed.inMilliseconds;

        KaraAction action = _actionQueue.removeFirst();
        try {
          action(speed);
        } on KaraException catch(e) {
          // Show the exception to the user.
          html.window.alert(e.toString());
          _enterFrameSub.cancel();
        }
      }
    } else {
      // No action in queue, call all actor's act()-method.
      try {
        // Create a list copy so we can modify the original list during the
        // iteration.
        var listCopy = actors.toList();
        listCopy.forEach((actor) => actor.act());

      } on StopException {
        // Stop execution after all queued actions have been processed.
        _actionQueue.add((spd) {
          _enterFrameSub.cancel();
        });

      } on ActOverflowException catch (e) {
        // Stop execution after all queued actions have been processed.
        _actionQueue.add((spd) {
          _enterFrameSub.cancel();
          html.window.alert(e.toString());
        });
      }
    }
  }

  /// Renders the current world state with [actors] and [kara].
  ///
  /// Note: The rendering is not done immediately. The current world state is
  /// added to a queue where itmes are rendered with a fixed delay between them.
  void queueAction(KaraAction action) {
    // Add the current world state at the end of the queue.
    _actionQueue.add(action);

    if (_actionQueue.length > maxActActions) {
      // The maximum number of actions during one act()-call has been reached.
      throw new ActOverflowException(messages.actOverflowException());
    }
  }

  /// Returns a list of actors at the specified location.
  List<Actor> getActorsAt(int x, int y) {
    return actors.where((Actor actor) => actor.x == x && actor.y == y)
        .toList(growable: false);
  }

  /// Returns a list of actors that are a number of [steps] away from [x], [y]
  /// in the specified [direction].
  List<Actor> getActorsInFront(int x, int y, int direction, [int steps = 1]) {
    switch (direction) {
      case directionRight:
        x = (x + steps) % scenario.width;
        break;
      case directionDown:
        y = (y + steps) % scenario.height;
        break;
      case directionLeft:
        x = (x - steps) % scenario.width;
        break;
      case directionUp:
        y = (y - steps) % scenario.height;
        break;
    }

    return getActorsAt(x, y);
  }
}

/// The type for a [Kara] action function.
typedef void KaraAction(Duration speed);

/// Exception for errors created by the user who implemented the act()-method.
class KaraException implements Exception {

  /// A message describing the kara exception.
  final String message;

  /// Creates a new [KaraException] with an optional error [message].
  KaraException([this.message = '']);

  String toString() {
    if (message != null && message.isNotEmpty) {
      return message;
    } else {
      return messages.karaExceptionDefault();
    }
  }
}

/// Exception that is thrown when the user created an act()-method that does
/// not terminate in a reasonable time. That means it calls more than the
/// allowed number of Kara action methods ([maxActActions]).
class ActOverflowException extends KaraException {
  ActOverflowException([String message = '']) : super(message);
}

/// Exception used to stop the execution inside the act()-method.
class StopException implements Exception {}

