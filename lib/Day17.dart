
import 'dart:io';
import 'package:Advent_of_Code_2019/Day03.dart';
import 'package:Advent_of_Code_2019/Point.dart';
import 'package:Advent_of_Code_2019/Rect.dart';
import 'package:Advent_of_Code_2019/IntcodeComputer.dart';

const SCAFFOLD = 35;
const OPENSPACE = 46;
const LINEFEED = 10;

Future<void> day17() async {
  var file = File('input/Day17.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s)).toList();

    // var c = IntcodeComputer(List<int>.from(startingMemory), []);
    // c.printProgram();

    var computer = IntcodeComputer(startingMemory, []);
    computer.execute();

    var width = computer.output.indexWhere((c) => c == LINEFEED);
    var height = (computer.output.length / width).ceil();
    var grid = Grid(Rect(0, 0, height, width));
    var point = Point(0, height);
    var startPoint = Point.origin();
    for (var value in computer.output) {
      if (value == LINEFEED) {
        point.x = 0;
        point.y--;
      } else {
        if (value == '^'.codeUnitAt(0)) {
          startPoint = point.copy();
        }
        grid.set(point, String.fromCharCode(value));
        point.x++;
      }
    }
    List<Point> crossings = findCrossings(grid, startPoint);
//    grid.draw();
//    print('Size $height * $width');
//    print('startPoint $startPoint');
//    for(var p in crossings) {
//      print('$p -> ${p.x + (height - p.y)}');
//    }
    var part1 = crossings.fold(0, (sum, p) => sum + p.x * (height - p.y));
    print('Part 1: $part1');
  }
}

List<Point> findCrossings(Grid grid, Point start) {
  var path = Set<Point>();
  var crossings = List<Point>();
  Point position = start.copy();
  Point direction = Point(-1, 0);
  while (true) {
    while (grid.get(position + direction) == '#') {
      position += direction;
      if (path.contains(position)) {
        crossings.add(position.copy());
        grid.set(position, 'O');
      } else {
        path.add(position);
      }
    }
    if (grid.get(position + direction.turnLeft()) == '#') {
      direction = direction.turnLeft();
    } else {
      if (grid.get(position + direction.turnRight()) == '#') {
        direction = direction.turnRight();
      } else {
        return crossings;
      }
    }
  }
}