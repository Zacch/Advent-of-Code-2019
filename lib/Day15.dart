import 'dart:collection';
import 'dart:io';
import 'Grid.dart';
import 'Point.dart';
import 'Rect.dart';
import 'IntcodeComputer.dart';

const SIZE = 22;
var startingMemory = List<int>();
var grid = Grid(Rect(-SIZE, -SIZE, SIZE, SIZE));
Point oxygenPosition;

Future<void> day15() async {
  var file = File('input/Day15.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    startingMemory = parts.map((s) => int.parse(s)).toList();

     // var c = IntcodeComputer(List<int>.from(startingMemory), []);
     // c.printProgram();

    grid.set(Point.origin(), '@');
    var pathToOxygen = findNearestOxygen();
    // grid.draw();
    print('Part 1: ${pathToOxygen.length}');

    var longestPath = findLongestPath(getPosition(pathToOxygen, Point.origin()));
    print('Part 2: ${longestPath.length}');
  }
}

List<int> findNearestOxygen() {
  var shortestOxygenPath = List<int>();
  var frontier = Queue<List<int>>();
  frontier.add(List<int>());
  var visited = Set<Point>();
  while (frontier.isNotEmpty) {
    var current = frontier.removeFirst();
    for (var nextMove in [1, 2, 3, 4]) {
      var moves = List<int>.from(current);
      moves.add(nextMove);
      var position = Point.origin();
      position = getPosition(moves, position);
      if (!visited.contains(position)) {
        var computer = IntcodeComputer(List<int>.from(startingMemory), List<int>.from(moves));
        computer.execute();
        var status = computer.output.last;
        switch (status) {
          case 0: // Wall
            grid.set(position, '#');
            break;
          case 1: // Empty
            grid.set(position, '.');
            frontier.add(moves);
            break;
          case 2: // Oxygen
            grid.set(position, 'O');
            if (shortestOxygenPath.isEmpty) {
              shortestOxygenPath = moves;
            }
            frontier.add(moves);
            break;
        }
        visited.add(position);
      }
    }
  }
  return shortestOxygenPath;
}

List<int> findLongestPath(Point startPosition) {
  var longestPath = List<int>();
  var frontier = Queue<List<int>>();
  frontier.add(List<int>());
  var visited = Set<Point>();
  while (frontier.isNotEmpty) {
    var current = frontier.removeFirst();
    for (var nextMove in [1, 2, 3, 4]) {
      var moves = List<int>.from(current);
      moves.add(nextMove);
      var position = getPosition(moves, startPosition);
      if (!visited.contains(position)) {
        if (grid.get(position) != '#') {
          frontier.add(moves);
        }
        visited.add(position);
        longestPath = moves;
      }
    }
  }
  return longestPath;
}

Point getPosition(List<int> moves, Point startPosition) {
  var currentPosition = startPosition;
  for (var move in moves) {
    switch (move) {
      case 1: // North
        currentPosition += Point(0, 1);
        break;
      case 2: // South
        currentPosition += Point(0, -1);
        break;
      case 3: // West
        currentPosition += Point(-1, 0);
        break;
      case 4: // East
        currentPosition += Point(1, 0);
        break;
    }
  }
  return currentPosition;
}
