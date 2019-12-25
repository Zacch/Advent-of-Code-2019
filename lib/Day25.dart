
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

    print('Advent of Code 2019, final puzzle');
    print('---------------------------------');
    print("Feel free to explore Santa's ship and look for the password for the main airlock.");
    print('You can enter s, n, e, w to move and use "save" and "load" if you like.');

    var save = List<int>.from(startingMemory);

    // Load saved game
    var saveFile = File('input/Day25(Saved Game).txt');
    if (await saveFile.exists()) {
      var savedContents = await saveFile.readAsString();
      var savedParts = savedContents.split(',');
      save = savedParts.map((s) => int.parse(s)).toList();
      print('\nA saved game with the solution has been provided.');
      print('To cheat, just type "load" followed by "s"!');
    }

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
          print('Game loaded!\n\nCommand?');
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