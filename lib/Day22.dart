import 'dart:io';

Future<void> day22() async {
  var file = File('input/Day22.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();

    var deck = SpaceDeck(10007);
    for (var line in contents) {
      var words = line.split(' ');
      switch (words[0]) {
        case 'cut':
          deck.cut(int.parse(words[1]));
          break;
        case 'deal':
          if (words[2] == 'new') {
            deck.dealIntoNewStack();
          } else {
            deck.dealWithIncrement(int.parse(words[3]));
          }
      }
    }
    print('Part 1: ${deck.cards.indexOf(2019)}');
  }
}

class SpaceDeck {
  int length;
  List<int> cards;

  SpaceDeck(this.length) {
    cards = List<int>.generate(length, (i) => i);
  }

  void dealIntoNewStack() {
    cards = cards.reversed.toList(growable: false);
  }

  void cut(int count) {
    count = count % length;
    var newCards = List<int>(length);
    newCards.setRange(0, length - count, cards.getRange(count, length));
    newCards.setRange(length - count, length, cards.getRange(0, count));
    cards = newCards;
  }

  void dealWithIncrement(int increment) {
    var newCards = List<int>(length);
    for (var i = 0; i < length; i++) {
      newCards[i * increment % length] = cards[i];
    }
    cards = newCards;
  }
}