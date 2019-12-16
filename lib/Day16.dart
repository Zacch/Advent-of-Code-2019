
import 'dart:io';

final ZERO = '0'.codeUnitAt(0);
final ITERATIONS = 100;

Future<void> day16() async {
  var file = File('input/Day16.txt');

  if (await file.exists()) {
    var raw = await file.readAsString();
    var contents = raw.codeUnits.map((d) => d - ZERO).toList();
    var input = List<int>.from(contents);

    var patterns = makePatterns(input.length);
    for (var i = 1; i <= ITERATIONS; i++) {
      input = fft(input, patterns);
    }
    var output = String.fromCharCodes(input.map((d) => d + ZERO));
    print('Part 1: ${output.substring(0, 8)}');

//    input.clear();
//    for (var i = 0; i < 1000; i++) {
//      input.addAll(contents);
//    }
//    patterns.clear();
//    patterns = makePatterns(input.length);
//    for (var i = 1; i <= ITERATIONS; i++) {
//      input = fft(input, patterns);
//      print(i);
//    }
//    int offset = int.parse(raw.substring(0, 7));
//    print('Offset $offset');
//    output = String.fromCharCodes(input.map((d) => d + ZERO));
//    print('Part 2: ${output.substring(0, 8)}');
  }
}

List<List<int>> makePatterns(int minimumLength) {
  var patterns = List<List<int>>();
  for (int iteration = 1; iteration <= minimumLength; iteration++) {
    var patternStart = List<int>();
    for (int factor in [0, 1, 0, -1]) {
      for (int i = 0; i < iteration; i++) {
        patternStart.add(factor);
      }
    }
    var pattern = List<int>.from(patternStart);
    while (pattern.length <= minimumLength) {
      pattern.addAll(patternStart);
    }
    pattern.removeAt(0);
    patterns.add(pattern);
  }
  return patterns;
}

List<int> fft(List<int> input, List<List<int>> patterns) {
  var output = List<int>();
  for (int iteration = 0; iteration < input.length; iteration++) {
    var pattern = patterns[iteration];
    var sum = 0;
    for(int j = 0; j < input.length; j++) {
      sum += input[j] * pattern[j];
    }
    output.add(sum.abs() % 10);
  }

  return output;
}