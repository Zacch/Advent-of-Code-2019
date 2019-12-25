
import 'dart:io';
import 'IntcodeComputer.dart';

const macros = {'s': 'south', 'n': 'north', 'e': 'east', 'w': 'west'};

Future<void> day25() async {
  var file = File('input/Day25.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s)).toList();

    // var c = IntcodeComputer(List<int>.from(startingMemory), []);
    // c.printProgram();

    var computer = IntcodeComputer(List.from(startingMemory), []);
    computer.execute();

    var save = List<int>.from(computer.memory);

    print(String.fromCharCodes(computer.output));
    computer.output.clear();
    while (true) {
      var command = stdin.readLineSync();
      command = macros[command] ?? command;
      switch (command) {
        case 'save':
          print(computer.memory);
          save = List<int>.from(computer.memory);
          continue;
          break;
        case 'load':
          computer.memory = List<int>.from(save);
          continue;
          break;
      }
      var input = List<int>.from(command.codeUnits);
      input.add(10);
      computer.continueWithNewInput(input);
      print(String.fromCharCodes(computer.output));
      computer.output.clear();
    }
  }
}