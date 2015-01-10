
import 'package:kara/kara.dart';
import 'scenarios.dart';

/// MyKara ist eine Unterklasse von Kara. Sie erbt damit alle Methoden der 
/// Klasse Kara:
/// 
/// Aktionen: move(), turnLeft(), turnRight(), putLeaf(), removeLeaf()
/// Sensoren: onLeaf(), treeFront(), treeLeft(), treeRight(), mushroomFront()
/// 
class MyKara extends Kara {
  
  /// In der Methode 'act()' koennen die Befehle fuer Kara programmiert werden.
  void act() {
    move();
    move();
    move();
    move();
    stop();
//    move();
//    turnLeft();
//    for(int i = 0; i < 2; i++) {
//      move();
//    }
    
//    if (treeFront()) {
//      goAroundTree();
//    } else {
//      if (onLeaf()) {
//        removeLeaf();
//      } else {
//        move();
//      }
//    }
  }
  
  void goAroundTree() {
    turnLeft();
    move();
    turnRight();
    move();
    move();
    turnRight();
    move();
    turnLeft();
  }
}

void main() {
  start(scenario04b(), new MyKara(), new Duration(milliseconds: 1000));
}  



