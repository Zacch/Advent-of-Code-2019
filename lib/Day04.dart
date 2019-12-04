
final zero = "0".codeUnitAt(0);

Future<void> day04() async {
  int part1 = 0;
  int part2 = 0;

  for (var i = 234208; i <= 765869; i++) {
    if (validPassword(i)) {
      part1++;
    }
    if (validPasswordForPart2(i)) {
      part2++;
    }
  }

  print('Part 1: $part1');
  print('Part 2: $part2');
}

bool validPassword(int i) {
  var digits = i.toString();

  var lastDigit = -1;
  var adjacentDigitsFound = false;
  for (var c in digits.codeUnits) {
    var digit = c - zero;
    if (digit < lastDigit) {
      return false;
    }
    if (digit == lastDigit) {
      adjacentDigitsFound = true;
    }
    lastDigit = digit;
  }
  return adjacentDigitsFound;
}

// Copy-paste FTW :P
bool validPasswordForPart2(int i) {
  var digits = i.toString();

  var lastDigit = -1;
  var pairFound = false;
  var runLength = 1;
  for (var c in digits.codeUnits) {
    var digit = c - zero;
    if (digit < lastDigit) {
      return false;
    }
    if (digit == lastDigit) {
      runLength++;
    } else {
      if (runLength == 2) {
        pairFound = true;
      }
      runLength = 1;
    }
    lastDigit = digit;
  }
  return pairFound || runLength == 2;
}