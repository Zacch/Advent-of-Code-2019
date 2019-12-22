import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:Advent_of_Code_2019/Point.dart';
import 'package:Advent_of_Code_2019/Rect.dart';

import 'Grid.dart';

var a = 'a'.codeUnitAt(0);
var z = 'z'.codeUnitAt(0);
var A = 'A'.codeUnitAt(0);
var Z = 'Z'.codeUnitAt(0);
var WALL = '#'.codeUnitAt(0);
var ENTRANCE = '@'.codeUnitAt(0);

var allPaths = Map<int, List<Path>>();
var shortestPathLength = 1000000000;
int shortestPathOverall = 1000000000;

Future<void> day18() async {
  var file = File('input/Day18.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var h = contents.length;
    var w = contents[0].length;
    var grid = Grid(Rect(1, 0, h, w - 1));
    var p = Point(0, h);
    var entrance = Point.origin();
    var keys = Map<int, Point>();
    for (var line in contents) {
      line.codeUnits.forEach((c) {
        grid.set(p, String.fromCharCode(c));
        if (c == ENTRANCE) {
          entrance = p.copy();
        }
        if (isKey(c)) {
          keys[c] = p.copy();
        }
        p.x++;
      });
      p.y--;
      p.x = 0;
    }
    grid.draw();
    print('Entrance: $entrance');
    print('Keys -> positions: $keys');

    var pathsFromEntrance = keyPaths(entrance, grid);
//    print('\nPaths from the entrance to each key:\n$pathsFromEntrance');
    for (var key in keys.keys) {
      allPaths[key] = keyPaths(keys[key], grid);
    }
//    print('\nPaths from each key to all other keys:\n$allPaths');
    // Now we have all we need to solve part 1!

    print('shortestPathOverall: $shortestPathOverall');
    var part1 = aStar(pathsFromEntrance, allPaths);
    print('Part 1: $part1');
  }
}

bool isKey(int c) {
  return c >= a && c <= z;
}
bool isLock(int c) {
  return c >= A && c <= Z;
}
int lockToKey(int lock) {
  return lock - A + a;
}

// Breadth-first search for all keys in grid
List<Path> keyPaths(Point start, Grid grid) {
  var result = List<Path>();
  var frontier = Queue<Path>();
  frontier.add(Path(start));
  var visited = [start];

  while (frontier.isNotEmpty) {
    var current = frontier.removeFirst();
    for (var nextMove in [Point(0, 1), Point(0, -1), Point(-1, 0), Point(1, 0)]) {
      var nextPosition = current.end + nextMove;
      if (!visited.contains(nextPosition)) {
        var content = grid.get(nextPosition).codeUnitAt(0);
        if (content != WALL) {
          var nextPath = current.copyAndAddPosition(nextPosition);
          if (isKey(content)) {
            nextPath.key = content;
            result.add(nextPath);
            shortestPathOverall = min(shortestPathOverall, nextPath.length);
          }
          if (isLock(content)) {
            nextPath.locks.add(lockToKey(content));
          }
          frontier.add(nextPath);
          visited.add(nextPosition);
        }
      }
    }
  }
  return result;
}

// Depth-first search didn't work so well. This is the output after two DAYS of execution:
// Tried 4645500000 paths so far. Shortest is 4896
// Tried 4645510000 paths so far. Shortest is 4896
// Tried 4645520000 paths so far. Shortest is 4896
// Tried 4645530000 paths so far. Shortest is 4896

var pathsTried = 0;

// Dept-first recursive
void findShortestPath(List<Path> paths, int lengthSoFar, List<Path> pathsTaken, Map<int, List<Path>> futurePaths) {
  var keysTaken = pathsTaken.map((path) => path.key);
  if (futurePaths.isEmpty) {
    if (lengthSoFar < shortestPathLength) {
      print('New Shortest Path ($lengthSoFar): ${keysTaken.map((k) => String.fromCharCode(k))}');
      shortestPathLength = lengthSoFar;
    }
    pathsTried++;
    if (pathsTried % 10000 == 0) {
      print('Tried $pathsTried paths so far. Shortest is $shortestPathLength');
    }
    return;
  }
  var possiblePaths = paths.where((path) => path.locks.where((lock) => !keysTaken.contains(lock)).isEmpty);
  if (possiblePaths.isEmpty) {
    print('Dead End with keys $keysTaken at $paths!');
    return;
  }
  for (var path in possiblePaths) {
    if (futurePaths.containsKey(path.key)) {
      var nextPaths = futurePaths[path.key];
      var nextPathsTaken = List<Path>.from(pathsTaken);
      nextPathsTaken.add(path);
      var nextFuturePaths = Map<int, List<Path>>.from(futurePaths);
      nextFuturePaths.remove(path.key);
      findShortestPath(nextPaths, lengthSoFar + path.length, nextPathsTaken, nextFuturePaths);
    }
  }
}

//---------------------------------------------------------
// Modified A* search for the shortest path

int aStar(List<Path> pathsFromEntrance, Map<int, List<Path>> allPathsBetweenKeys) {
  var frontier = SplayTreeMap<int, List<PathList>>();
  var start = PathList([], pathsFromEntrance, allPathsBetweenKeys);

  frontier[0] = [start];

  var iterations = 0;

  while (frontier.isNotEmpty) {
    var firstKey = frontier.firstKey();
    var current = frontier[firstKey].removeAt(0);
    if (frontier[firstKey].isEmpty) {
      frontier.remove(firstKey);
    }

    var keysTaken = current.pathsTaken.map((path) => path.key);
    if ( ++iterations % 10000 == 0) {
      print('Iterations so far: $iterations. Priority ${current.priority}. Paths in frontier: ${frontier.values.fold(0, (s, list) => s + list.length)}.');
    }
    if (current.futurePaths.isEmpty) {
      print('The shortest path is ${keysTaken.map((k) => String.fromCharCode(k))} (${current.length})');
      return current.length;
    }
    var possiblePaths = current.outgoingPaths.where(
            (path) => !keysTaken.contains(path.key) && path.locks.where((lock) => !keysTaken.contains(lock)).isEmpty);
    if (possiblePaths.isEmpty) {
      print('Dead End with keys $keysTaken at ${current.pathsTaken}!');
      return -1;
    }
    for (var path in possiblePaths) {
      var nextOutgoingPaths = current.futurePaths[path.key];
      var nextPathsTaken = List<Path>.from(current.pathsTaken);
      nextPathsTaken.add(path);
      var nextFuturePaths = Map<int, List<Path>>.from(current.futurePaths);
      nextFuturePaths.remove(path.key);
      var next = PathList(nextPathsTaken, nextOutgoingPaths, nextFuturePaths);
      if (frontier.containsKey(next.priority)) {
        frontier[next.priority].add(next);
      } else {
        frontier[next.priority] = [next];
      }
    }
  }
  return 0;
}
//---------------------------------------------------------
  class Path {
  int key = 0;
  var length = 0;
  var locks = List<int>();
  var end = Point.origin();

  Path(this.end);

  Path copy() {
  var copy = Path(end);
  copy.length = length;
  copy.locks.addAll(locks);
  return copy;
  }

  Path copyAndAddPosition(Point nextPosition) {
  var result = copy();
  result.length++;
  result.end = nextPosition;
  return result;
  }

  @override String toString() {
  return 'Path{to:$key length: $length, locks: $locks, end: $end}\n';
  }

  @override bool operator ==(Object other) =>
  identical(this, other) || other is Path && runtimeType == other.runtimeType && end == other.end;

  @override int get hashCode => end.hashCode;
  }

//---------------------------------------------------------
  class PathList {
  var pathsTaken = List<Path>();
  var outgoingPaths = List<Path>();
  var futurePaths = Map<int, List<Path>>();
  int get length => pathsTaken.fold(0, (s, p) => s + p.length);

  // This is the heuristic we use for the A* search – it will never overestimate the
  // distance to the goal, so we will find the shortest path.
  int get priority => length + futurePaths.keys.length * shortestPathOverall;

  PathList(this.pathsTaken, this.outgoingPaths, this.futurePaths);

  @override
  bool operator ==(Object other) =>
  identical(this, other) ||
  other is PathList &&
  runtimeType == other.runtimeType &&
  priority == other.priority;

  @override
  int get hashCode => pathsTaken.toString().hashCode;
  }