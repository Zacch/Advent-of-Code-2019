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

    ShuffleTechnique move = DealIntoNewStack(10);
    print('DealIntoNewStack');
    print(List<int>.generate(10, (i) => i).map((i) => move.indexBefore(i)));

    move = Cut(3, 10);
    print('Cut 3');
    print(List<int>.generate(10, (i) => i).map((i) => move.indexBefore(i)));

    move = Cut(-4, 10);
    print('Cut -4');
    print(List<int>.generate(10, (i) => i).map((i) => move.indexBefore(i)));

    move = DealWithIncrement(3, 10);
    print('DealWithIncrement');
    print(List<int>.generate(10, (i) => i).map((i) => move.indexBefore(i)));
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

//----------------------------------------------------------------
abstract class ShuffleTechnique {
  int deckSize;
  ShuffleTechnique(this.deckSize);

  // Returns the index of the card that will end up at index position after the shuffle.
  int indexBefore(int position);
}

class DealIntoNewStack extends ShuffleTechnique {
  DealIntoNewStack(int decksize) : super(decksize);

  @override
  int indexBefore(int position) {
    return deckSize - position - 1;
  }
}

class Cut extends ShuffleTechnique {
  int cutSize;

  Cut(this.cutSize, int decksize) : super(decksize);

  @override
  int indexBefore(int position) {
    if (cutSize > 0) {
      if (position < deckSize - cutSize) {
        return position + cutSize;
      } else {
        return cutSize + position - deckSize;
      }
    }
    var size = -cutSize;
    if (position < size) {
      return deckSize - size + position ;
    } else {
      return position - size;
    }
  }
}

class DealWithIncrement extends ShuffleTechnique {
  int increment;
  List<int> startingIndices;

  DealWithIncrement(this.increment, int decksize) : super(decksize) {
    startingIndices = List<int>(increment);
    startingIndices[0] = 0;
    for (int i = 1; i < increment; i++) {
      var offset = (i * decksize) ~/ increment + 1;
      var index = offset * increment % decksize;
      startingIndices[index] = offset;
    }
  }

  @override
  int indexBefore(int position) {
    return startingIndices[position % increment] + (position ~/ increment);
  }
}
