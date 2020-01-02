
import 'dart:io';

import 'package:Advent_of_Code_2019/Point.dart';

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

    var natPacket = Point(-1, -1);
    var steps = 0;
    var natYvalues = Set<int>();
    var part2Done = false;
    while (!part2Done) {
      for (int i = 0; i < 50; i++) {
        var computer = network[i];
        if (computer.currentInstruction is Input && computer.input.isEmpty) {
          computer.input.add(-1);
        }
        computer.step();
        if (computer.output.length == 3) {
          var destination = computer.output[0];
          if (destination == 255) {
            if (natPacket.y == -1) {
              print('Part 1: ${computer.output[2]}');
            }
            natPacket.x = computer.output[1];
            natPacket.y = computer.output[2];
          } else {
            network[destination].input.add(computer.output[1]);
            network[destination].input.add(computer.output[2]);
          }
          computer.output.clear();
        }
        if (isIdle(network)) {
          network[0].input.add(natPacket.x);
          network[0].input.add(natPacket.y);
          if (natYvalues.contains(natPacket.y)) {
            print('Part 2: ${natPacket.y}');
            part2Done = true;
          }
          natYvalues.add(natPacket.y);
        }
      }
      if (++steps % 1000000 == 0) {
        print('${steps ~/ 1000000} million steps');
      }
    }
  }
}

bool isIdle(List<IntcodeComputer> network) {
  for (var computer in network) {
    if (computer.input.isNotEmpty) {
      return false;
    }
    if (computer.ip < 73 || computer.ip > 87) {
      return false;
    }
  }
  return true;
}
