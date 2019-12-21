
import 'dart:io';
import 'package:Advent_of_Code_2019/Day03.dart';
import 'package:Advent_of_Code_2019/Point.dart';
import 'package:Advent_of_Code_2019/Rect.dart';
import 'package:Advent_of_Code_2019/IntcodeComputer.dart';

const LINEFEED = 10;

var height = 0, width = 0;
Grid grid;
var startPoint = Point.origin();
var moves = "";

Future<void> day17() async {
  var file = File('input/Day17.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s)).toList();

    // var c = IntcodeComputer(List<int>.from(startingMemory), []);
    // c.printProgram();

    var computer = IntcodeComputer(List.from(startingMemory), []);
    computer.execute();

    parseOutput(computer.output);
    List<Point> crossings = findCrossings();
    // grid.draw();
    var part1 = crossings.fold(0, (sum, p) => sum + p.x * (height - p.y));
    print('Part 1: $part1');

    List<String> inputStrings = getInputStrings(moves);
    var input = List<int>();
    for (var s in inputStrings) {
      input.addAll(s.codeUnits);
      input.add(LINEFEED);
    }
    input.add('n'.codeUnitAt(0));
    input.add(LINEFEED);

    computer = IntcodeComputer(startingMemory, input);
    computer.memory[0] = 2;
    computer.execute();

    print('Part 2: ${computer.output.last}');
  }
}

parseOutput(List<int> output) {
  width = output.indexWhere((c) => c == LINEFEED);
  height = (output.length / width).ceil();
  grid = Grid(Rect(0, 0, height, width));
  var point = Point(0, height);
  for (var value in output) {
    if (value > 255) { return; }
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
}

List<Point> findCrossings() {
  var path = Set<Point>();
  var crossings = List<Point>();
  Point position = startPoint.copy();
  Point direction = Point(-1, 0);
  moves = 'L,';
  while (true) {
    int stepCount = 0;
    while (grid.get(position + direction) == '#') {
      stepCount++;
      position += direction;
      if (path.contains(position)) {
        crossings.add(position.copy());
        grid.set(position, 'O');
      } else {
        path.add(position);
      }
    }
    moves += stepCount.toString() + ',';
    if (grid.get(position + direction.turnLeft()) == '#') {
      direction = direction.turnLeft();
      moves += 'L,';
    } else {
      if (grid.get(position + direction.turnRight()) == '#') {
        direction = direction.turnRight();
        moves += 'R,';
      } else {
        moves = moves.substring(0, moves.length - 1);
        return crossings;
      }
    }
  }
}

// This would not work for all possible inputs,
// but it works well for mine.
List<String> getInputStrings(String moves) {
  var a = findRepeatedPrefix(moves);
  var aMoves = moves.replaceAll(a, 'A');

  var rest = aMoves;
  while (rest.startsWith('A,')) {
    rest = rest.substring(2);
  }
  var b = findRepeatedPrefix(rest);
  var bMoves = aMoves.replaceAll(b, 'B');

  rest = bMoves;
  while (rest.startsWith('A,') || rest.startsWith('B,')) {
    rest = rest.substring(2);
  }
  var c = findRepeatedPrefix(rest);
  var cMoves = bMoves.replaceAll(c, 'C');

  return [cMoves, a, b, c];
}

// A cool trick to check for ASCII digits. Wish I'd thought of it myself ;)
bool isDigit(String s, int idx) => (s.codeUnitAt(idx) ^ 0x30) <= 9;

String findRepeatedPrefix(String string) {
  var len = 20;
  while (len > 0) {
    var prefix = string.substring(0, len);
    if (isDigit(prefix, len - 1)) {
      if (RegExp("($prefix)").allMatches(string).length > 1) {
        return prefix;
      }
    }
    len--;
  }
  return '';
}
