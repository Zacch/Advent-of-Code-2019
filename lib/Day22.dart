import 'dart:io';

Future<void> day22() async {
  var file = File('input/Day22.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();

    var deckSize1 = 10007;
    var deckSize2 = 119315717514047;
    var deck = SpaceDeck(deckSize1);
    var techniques = List<ShuffleTechnique>();
    for (var line in contents) {
      var words = line.split(' ');
      switch (words[0]) {
        case 'cut':
          var cutSize = int.parse(words[1]);
          deck.cut(cutSize);
          techniques.add(Cut(cutSize, deckSize2));
          break;
        case 'deal':
          if (words[2] == 'new') {
            deck.dealIntoNewStack();
            techniques.add(DealIntoNewStack(deckSize2));
          } else {
            var increment = int.parse(words[3]);
            deck.dealWithIncrement(increment);
            techniques.add(DealWithIncrement(increment, deckSize2));
          }
      }
    }
    techniques = techniques.reversed.toList(growable: false);

    print('Part 1: ${deck.cards.indexOf(2019)}');

    // -----------------------------------------
    const totalIterations = 101741582076661;
    var cycleLength = 0;
    var currentPosition = 2020;
    while (true) {
      if (cycleLength % 1000000 == 0) {
        print('$cycleLength: $currentPosition');
      }
      currentPosition = getIndexBefore(currentPosition, techniques);
      cycleLength++;
      if (currentPosition == 2020) {
        print('Found cycle! $cycleLength: $currentPosition');
        break;
      }
    }
    print('cycleLength $cycleLength');
    //  40528000000: 44776915728345
    //  40529000000: 66142825362176
    //  40530000000: 105602838143656
    //  40531000000: 29871572303647

}
}

int getIndexBefore(int indexAfter, List<ShuffleTechnique> techniques) {
  var current = indexAfter;
  techniques.forEach((technique) { current = technique.indexBefore(current); });
  return current;
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
