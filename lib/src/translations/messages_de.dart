part of kara;

class MessagesDe implements Messages {

  String cantMoveBecauseOfTree() =>
      "Kara kann sich nicht bewegen wegen einem Baum!";

  String cantMoveBecauseOfMushroom() =>
      "Kara kann sich nicht bewegen, da er den Pilz nicht schieben kann!";

  String cantPutLeaf() =>
      "Kara kann kein Kleeblatt auf ein Feld legen, auf dem schon eines ist!";

  String cantRemoveLeaf() =>
      "Kara kann hier kein Blatt auflesen!";

  String karaExceptionDefault() =>
      "Kara hat ein Problem!";

  String actOverflowException() =>
      "Ihr Programm dauert zu lange oder beendet gar nicht!";
}