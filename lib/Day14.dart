import 'dart:io';

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
//    formulae.forEach((k,v) {
//      print('$v => $k');
//    });

    buildOneFuel();
    print('Part 1: $oreUsed');

//    int fuelProduced = 1;
//    var history = Map<String, int>();
//    var oreUsedHistory = [0, oreUsed];
//    history[leftovers.toString()] = fuelProduced;
//    print('fuelProduced: $fuelProduced, oreUsed: $oreUsed leftovers: $leftovers');
//
//    while (fuelProduced < 300) {
//      buildOneFuel();
//      fuelProduced++;
//      oreUsedHistory.add(oreUsed);
//      var leftOverString = leftovers.toString();
//      print('fuelProduced: $fuelProduced, oreUsed: $oreUsed leftovers: $leftOverString');
//      if (history.containsKey(leftOverString)) {
//        var loopStart = history[leftOverString];
//        print('Matches iteration $loopStart!');
//        var loopLength = fuelProduced - loopStart;
//        var loopOre = oreUsed - oreUsedHistory[loopStart];
//        print('loopLength: $loopLength, loopOre: $loopOre');
//
//        var loops = ONE_TRILLION ~/ loopOre;
//        var oreLeft = ONE_TRILLION - loops * loopOre;
//        var part2 = loops * loopLength;
//        print('loops: $loops, oreLeft: $oreLeft, total fuel: $part2');
//
//        oreUsed = 0;
//        while (oreUsed < oreLeft)  {
//          part2++;
//          buildOneFuel();
//        }
//        print('Part 2: $part2');
//        print('Part 2: 82892753');
//        //break;
//      }
//    }
//
  }
}

void buildOneFuel() {
  var needed = Map<String, int>();

  for (var reagent in formulae[Reagent(1, "FUEL")]) {
    needed[reagent.name] = reagent.amount;
  }
  var totalNeeded = Map<String, int>();  // ------ Not used!
  while (needed.isNotEmpty) {
 //   print('ore $oreUsed + $needed.   Leftovers $leftovers    Total needed: $totalNeeded');
    var chemical = needed.keys.first;
    var amountNeeded = needed[chemical];
    if (leftovers.containsKey(chemical)) {
      var leftover = leftovers[chemical];
      if (amountNeeded < leftover) {
        leftovers[chemical] -= amountNeeded;
        continue;
      }
      amountNeeded -= leftover;
      leftovers.remove(chemical);
      if (amountNeeded == 0) { continue; }
    }
    needed.remove(chemical);
    var resultingAmount = formulae.keys.firstWhere((k) => k.name == chemical).amount;
    var batches = (amountNeeded / resultingAmount).ceil();
    var extra = batches * resultingAmount - amountNeeded;
    if (extra > 0) {
      leftovers[chemical] = extra;
    }
    var formula = formulae[Reagent(amountNeeded, chemical)];
    for (var reagent in formula) {
      if (reagent.name == "ORE") {
        totalNeeded[chemical] = (totalNeeded[chemical] ?? 0) + amountNeeded;
        oreUsed += batches * reagent.amount;
        continue;
      }

      var reagentAmountNeeded = reagent.amount * batches;
      if (leftovers.containsKey(reagent.name)) {
        var leftover = leftovers[reagent.name];
        if (reagentAmountNeeded < leftover) {
          leftovers[reagent.name] -= reagentAmountNeeded;
          continue;
        }
        reagentAmountNeeded -= leftover;
        leftovers.remove(reagent.name);
        if (reagentAmountNeeded == 0) { continue; }
      }

      if (needed.containsKey(reagent.name)) {
        needed[reagent.name] += reagentAmountNeeded;
      } else {
        needed[reagent.name] = reagentAmountNeeded;
      }
    }
  }
}