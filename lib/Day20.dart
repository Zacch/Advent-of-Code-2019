
import 'dart:collection';
import 'dart:io';

import 'Grid.dart';
import 'Point.dart';
import 'Rect.dart';

var A = 'A'.codeUnitAt(0);
var Z = 'Z'.codeUnitAt(0);
var VOID = ' '.codeUnitAt(0);

Grid grid;
var connections = Map<Point, Point>();

Future<void> day20() async {
  var file = File('input/Day20.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var h = contents.length;
    var w = contents[0].length;
    grid = Grid(Rect(0, 0, h - 1, w - 1));
    var p = Point(0, 0);
    for (var line in contents) {
      line.codeUnits.forEach((c) {
        grid.set(p, String.fromCharCode(c));
        p.x++;
      });
      p.y++;
      p.x = 0;
    }

    var teleports = Map<String, List<Point>>();
    var ignoreLetterAt = List<Point>();
    for (p.y = 0; p.y < h; p.y++) {
      for (p.x = 0; p.x < w; p.x++) {
        var c = grid.getChar(p);
        if (isLetter(c) && !ignoreLetterAt.contains(p)) {
          var p2 = p + Point(0, 1);
          var c2 = grid.getChar(p2);
          var teleport = p + Point(0, 2);
          if (!teleport.isInside(grid.bounds) || grid.getChar(teleport) == VOID) {
            teleport = p + Point(0, -1);
          }
          if (!isLetter(c2)) {
            p2 = p + Point(1, 0);
            c2 = grid.getChar(p + Point(1, 0));
            teleport = p + Point(2, 0);
            if (!teleport.isInside(grid.bounds) || grid.getChar(teleport) == VOID) {
              teleport = p + Point(-1, 0);
            }
          }
          if (!isLetter(c2)) {
            print('ERROR at $p (${String.fromCharCode(c)})');
            return;
          }
          ignoreLetterAt.add(p2);
          var teleportName = String.fromCharCodes([c, c2]);
          print('Found ${teleportName} at $p');
          if (!teleports.containsKey(teleportName)) {
            teleports[teleportName] = List<Point>();
          }
          teleports[teleportName].add(teleport);
        }
      }
    }
    var start = teleports['AA'].first;
    var goal = teleports['ZZ'].first;
    teleports.remove('AA');
    teleports.remove('ZZ');
    print(teleports);
    print('Start $start, Goal $goal');
    for (var points in teleports.values) {
      connections[points[0]] = points[1];
      connections[points[1]] = points[0];
    }
    print(connections);
//    connections.keys.forEach((p) {grid.set(p, '*');});
//    grid.set(start, 's');
//    grid.set(goal, 'g');

    print('Part 1: ${shortestPath(start, goal)}');
    grid.draw();
  }
}

int shortestPath(Point start, Point goal) {
  var frontier = Queue<List<Point>>();
  frontier.add([start]);
  var visited = List<Point>();
  visited.add(start);

  while (frontier.isNotEmpty) {
    var current = frontier.removeFirst();
    var p = current.last;
    var possibleMoves = [p + Point.UP, p + Point.DOWN, p + Point.LEFT, p + Point.RIGHT];
    if (connections.containsKey(p)) {
      possibleMoves.add(connections[p]);
    }
    for (var move in possibleMoves) {
      if (visited.contains(move)) {
        continue;
      }
      if (!(grid.get(move) == '.')) {
        continue;
      }

      var next = List<Point>.from(current);
      next.add(move);
      if (move == goal) {
        next.forEach((p) {grid.set(p, '_');});
        return (next.length - 1);
      }
      frontier.add(next);
      visited.add(move);
    }
  }
  return -1;
}


bool isLetter(int c) {
  return c >= A && c <= Z;
}
