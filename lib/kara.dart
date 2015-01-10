library kara;

import 'dart:html' as html;
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:stagexl/stagexl.dart';

part 'src/actors/actor.dart';
part 'src/actors/kara.dart';
part 'src/actors/leaf.dart';
part 'src/actors/mushroom.dart';
part 'src/actors/tree.dart';

part 'src/world/world.dart';
part 'src/world/scenario.dart';

part 'src/translations/messages.dart';
part 'src/translations/messages_de.dart';

/// The asset directory.
const String assetDir = 'packages/kara/assets';

/// Size of a cell in pixels (must match the image sizes).
const int cellSize = 28;

/// Size of the cell border in pixels.
const int cellBorderSize = 1;

/// The translated messages.
///
/// For other languages, set this variable to another [Messages] object.
/// Example for German:
///     messages = new MessagesDe();
///
Messages messages = new Messages();

/// Initializes the world with the specified [scenario] and shows it.
/// [kara] is the instance where the behaviour of Kara is programmed in.
void start(Scenario scenario, Kara kara,
           [Duration speed = const Duration(milliseconds: 300)]) {
  World world = new World(scenario, kara, speed);
}