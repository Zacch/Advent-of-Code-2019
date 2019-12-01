import 'dart:io';

int fuelNeededFor(int weight) {
  return (weight / 3).floor() - 2;
}

Future<void> day1() async {
  var file = File('input/day1.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    int part1 = 0;
    int part2 = 0;
    for (var string in contents) {
      int weight = int.parse(string);
      var fuel = fuelNeededFor(weight);
      part1 += fuel;
      while (fuel > 0) {
        part2 += fuel;
        fuel = fuelNeededFor(fuel);
      }
    }
    print('Part 1: $part1');
    print('Part 2: $part2');
  }
}