
import 'dart:io';

import 'IntcodeComputer.dart';

Future<void> day21() async {
  var file = File('input/Day21.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s)).toList();

    var computer = IntcodeComputer(List.from(startingMemory), []);
    computer.execute();

    // Program evolution :)
    //    var program = ['WALK'];
    //    var program = ['NOT A J', 'WALK'];
    //    var program = ['AND T J', 'OR D J', 'WALK'];
    //    var program = ['NOT D T', 'NOT T J', 'WALK'];

    // Jump if A is empty, or if C is empty and D has ground
    var program = ['NOT A J', 'NOT C T', 'AND D T', 'OR T J', 'WALK'];

    computer.continueWithNewInput(encode(program));
    print('Part 1: ${computer.output.last}');

    computer = IntcodeComputer(List.from(startingMemory), []);
    computer.execute();

    // Program evolution (in logic notation)
    // ~A
    // ~A + D
    // ~A + ~C * D
    // ~A + ~C * D * H
    // ~A + (~C + I) * D * H
    // (~C + I) * D * H * ~B + ~A
    // (~C + I) * D * H * (~B + ~C) + ~A
    // (~B + ~C + I) * D * H + ~A
    // (~B + ~C + (I * E)) * D * H + ~A
    // Success :)

    program = [
      'NOT B T',
      'NOT C J',
      'OR T J',
      'NOT I T',
      'NOT T T',
      'AND E T',
      'OR T J',
      'AND D J',
      'AND H J',
      'NOT A T',
      'OR T J',
      'RUN'];

    computer.continueWithNewInput(encode(program));
    print('Part 2: ${computer.output.last}');
  }
}

List<int> encode(List<String> program) {
  var input = List<int>();
  for (var line in program) {
    input.addAll(line.codeUnits);
    input.add(10);
  }
  return input;
}

void printOutput(IntcodeComputer computer) {
  print(computer.output.fold("", (s, int c) => s.toString() + String.fromCharCode(c)));
  computer.output.clear();
}