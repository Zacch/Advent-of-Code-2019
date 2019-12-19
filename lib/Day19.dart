import 'dart:io';

import 'package:Advent_of_Code_2019/Day03.dart';
import 'package:Advent_of_Code_2019/Point.dart';
import 'package:Advent_of_Code_2019/Rect.dart';

import 'IntcodeComputer.dart';

var startingMemory = List<int>();

Future<void> day19() async {
  var file = File('input/Day19.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    startingMemory = parts.map((s) => int.parse(s)).toList();

    // var c = IntcodeComputer(List<int>.from(startingMemory), []);
    // c.printProgram();

    var lastPointInside = Point.origin();
    var count = 0;
    for (int y = 0; y < 50; y++) {
      for (int x = 0; x < 50; x++) {
        var point = Point(x, y);
        if (isInBeam(point)) {
          lastPointInside = point;
          count++;
        }
      }
    }
    print('Part 1: $count');

    // rightEdge is just outside the beam
    var rightEdge = lastPointInside + Point(1, 0);
    var found = false;
    while (!found) {
      rightEdge.y++;
      while (isInBeam(rightEdge)) {
        rightEdge.x++;
      }
      if (isSquareToTheLeftInside(rightEdge)) {
        found = true;
      }
    }
    print('Part 2: ${(rightEdge.x - 100) * 10000 + rightEdge.y}');
  }
}

bool isInBeam(Point p) {
  var computer = IntcodeComputer(List<int>.from(startingMemory), [p.x, p.y]);
  computer.execute();
  return computer.output[0] == 1;
}

bool isSquareToTheLeftInside(Point rightEdge) =>
    isInBeam(Point(rightEdge.x - 100, rightEdge.y)) && isInBeam(Point(rightEdge.x - 100, rightEdge.y + 99)) &&
        isInBeam(Point(rightEdge.x, rightEdge.y + 99)) && isInBeam(Point(rightEdge.x - 1, rightEdge.y));
