import 'dart:io';

const ONE_TRILLION = 1000000000000;

var formulae = Map<Reagent, List<Reagent>>();
var leftovers = Map<String, int>();
var oreUsed = 0;

Future<void> day14() async {
  var file = File('input/Day14.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    await contents.forEach((line) {
      var parts = line.split(' => ').toList();
      if (parts.length != 2) { return; }
      var result = Reagent.parse(parts[1]);
      var ingredients = parts[0].split(', ').map((i) => Reagent.parse(i)).toList();
      formulae[result] = ingredients;
    });

    buildOneFuel();
    print('Part 1: $oreUsed');

    int fuelProduced = 1;

    // When in doubt, use brute force...  O.o
    while (oreUsed < ONE_TRILLION) {
      buildOneFuel();
      fuelProduced++;
      if (fuelProduced % 100000 == 0) {
        print('Please wait :). We still have ${ONE_TRILLION - oreUsed} ore to use');
      }
    }
    print('Part 2: ${fuelProduced - 1}');
  }
}

void buildOneFuel() {
  var needed = Map<String, int>();

  for (var reagent in formulae[Reagent(1, "FUEL")]) {
    needed[reagent.name] = reagent.amount;
  }
  while (needed.isNotEmpty) {
    var chemical = needed.keys.first;
    var amountNeeded = takeFromLeftovers(chemical, needed[chemical]);
    needed.remove(chemical);
    if (amountNeeded == 0) { continue; }
    var resultingAmount = formulae.keys
        .firstWhere((k) => k.name == chemical)
        .amount;
    var batches = (amountNeeded / resultingAmount).ceil();
    var extra = batches * resultingAmount - amountNeeded;
    if (extra > 0) {
      leftovers[chemical] = extra;
    }
    var formula = formulae[Reagent(amountNeeded, chemical)];
    for (var reagent in formula) {
      if (reagent.name == "ORE") {
        oreUsed += batches * reagent.amount;
        continue;
      }

      var reagentAmountNeeded = takeFromLeftovers(reagent.name, reagent.amount * batches);
      if (reagentAmountNeeded == 0) {
        continue;
      }

      if (needed.containsKey(reagent.name)) {
        needed[reagent.name] += reagentAmountNeeded;
      } else {
        needed[reagent.name] = reagentAmountNeeded;
      }
    }
  }
}

int takeFromLeftovers(String chemical, int reagentAmountNeeded) {
  if (leftovers.containsKey(chemical)) {
    var leftover = leftovers[chemical];
    if (reagentAmountNeeded < leftover) {
      leftovers[chemical] -= reagentAmountNeeded;
      return 0;
    }
    reagentAmountNeeded -= leftover;
    leftovers.remove(chemical);
  }
  return reagentAmountNeeded;
}

class Reagent {
  int amount = 0;
  String name;

  Reagent(this.amount, this.name);

  static Reagent parse(String string) {
    var parts = string.split(' ').toList();
    if (parts.length < 2) { return Reagent(0, string); }
    return Reagent(int.parse(parts[0]), parts[1]);
  }

  @override String toString() { return '$amount $name'; }

  @override bool operator ==(Object other) =>
      identical(this, other) ||
          other is Reagent && runtimeType == other.runtimeType && name == other.name;

  @override int get hashCode => name.hashCode;
}
