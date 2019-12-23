
import 'dart:io';

import 'IntcodeComputer.dart';
import 'IntcodeInstruction.dart';

Future<void> day23() async {
  var file = File('input/Day23.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s)).toList();

//    var computer = IntcodeComputer(List.from(startingMemory), []);
//    computer.printProgram();

    var network = List<IntcodeComputer>();
    for (var networkAddreess = 0; networkAddreess < 50; networkAddreess++) {
      var computer = IntcodeComputer(List.from(startingMemory), [networkAddreess]);
      computer.boot();
      network.add(computer);
    }

    var part1 = -1;
    while (part1 == -1) {
      for (var computer in network) {
        if (computer.currentInstruction is Input && computer.input.isEmpty) {
          computer.input.add(-1);
        }
        computer.step();
        if (computer.output.length == 3) {
          print('Output: ${computer.output}');
          var destination = computer.output[0];
          if (destination == 255) {
            part1 = computer.output[2];
          } else {
            network[destination].output.add(computer.output[1]);
            network[destination].output.add(computer.output[2]);
          }
          computer.output.clear();
        }
      }
    }
    print('Part 1: $part1');
  }
}
