import 'dart:collection';
import 'dart:io';

import 'package:Advent_of_Code_2019/Point.dart';
import 'package:Advent_of_Code_2019/Rect.dart';

import 'Grid.dart';

var a = 'a'.codeUnitAt(0);
var z = 'z'.codeUnitAt(0);
var A = 'A'.codeUnitAt(0);
var Z = 'Z'.codeUnitAt(0);
var WALL = '#'.codeUnitAt(0);
var ENTRANCE = '@'.codeUnitAt(0);

class State
{
  Point Position;
  int Keys;
  int Length;

  State(this.Position, this.Keys, this.Length);
}

class StatePart2
{
  List<Point> Positions;
  int Keys;
  int Length;

  StatePart2(this.Positions, this.Keys, this.Length);
}

Future<void> day18() async {
  var file = File('input/Day18.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var h = contents.length;
    var w = contents[0].length;
    var grid = Grid(Rect(1, 0, h, w - 1));
    var p = Point(0, h);
    var entrance = Point.origin();
    for (var line in contents) {
      line.codeUnits.forEach((c) {
        grid.set(p, String.fromCharCode(c));
        if (c == ENTRANCE) {
          entrance = p.copy();
        }
        p.x++;
      });
      p.y--;
      p.x = 0;
    }

    var part1 = search(grid, entrance);
    print('Part 1: $part1');

    grid.set(entrance + Point.UP + Point.LEFT, '@');
    grid.set(entrance + Point.UP, '#');
    grid.set(entrance + Point.UP + Point.RIGHT, '@');
    grid.set(entrance + Point.LEFT, '#');
    grid.set(entrance, '#');
    grid.set(entrance + Point.RIGHT, '#');
    grid.set(entrance + Point.DOWN + Point.LEFT, '@');
    grid.set(entrance + Point.DOWN, '#');
    grid.set(entrance + Point.DOWN + Point.RIGHT, '@');

    var part2 = searchPart2(grid, entrance);
    print('Part 2: $part2');
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

String EncodeReached(Point p, int keys)
{
  return p.toString() + ":" + keys.toString();
}

int search(Grid grid, Point startPosition) {
  var startState = new State(startPosition, 0, 0);

  var reached = new HashSet<String>();
  reached.add(EncodeReached(startPosition, 0));
  var frontier = new Queue<State>();
  frontier.add(startState);

  var shortestPath = 999999999;
  var mostKeys = 0;

  while (frontier.isNotEmpty)
  {
    var current = frontier.removeFirst();
    for (var nextPosition in current.Position.neighbours())
    {
      var content = grid.get(nextPosition).codeUnitAt(0);
      if (content == WALL) continue;
      if (isLock(content) && (current.Keys & (1 << (content - A))) == 0) continue;

      var newState = new State(nextPosition,
          isKey(content) ? current.Keys | (1 << (content - a)) : current.Keys,
          current.Length + 1);
      if (reached.contains(EncodeReached(nextPosition, newState.Keys))) continue;

      if (newState.Keys == mostKeys && newState.Length < shortestPath) shortestPath = newState.Length;

      if (newState.Keys > mostKeys)
      {
        mostKeys = newState.Keys;
        shortestPath = newState.Length;
      }

      reached.add(EncodeReached(nextPosition, newState.Keys));
      frontier.add(newState);
    }
  }

  return shortestPath;
}


int searchPart2(Grid grid, Point startPosition) {
  var startPositions = new List<Point>.generate(0, (index) => Point.origin());
  startPositions.add(startPosition + Point.UP + Point.LEFT);
  startPositions.add(startPosition + Point.UP + Point.RIGHT);
  startPositions.add(startPosition + Point.DOWN + Point.LEFT);
  startPositions.add(startPosition + Point.DOWN + Point.RIGHT);

  var startState = new StatePart2(startPositions, 0, 0);
  var reached = new HashSet<String>();
  reached.add(EncodeReached(startPosition, 0));
  var frontier = new Queue<StatePart2>();
  frontier.add(startState);

  var shortestPath = 999999999;
  var mostKeys = 0;

  while (frontier.isNotEmpty)
  {
    var current = frontier.removeFirst();
    for (var robot = 0; robot < current.Positions.length; robot++) {
      for (var nextPosition in current.Positions[robot].neighbours())
      {
        var content = grid.get(nextPosition).codeUnitAt(0);
        if (content == WALL) continue;
        if (isLock(content) && (current.Keys & (1 << (content - A))) == 0) continue;
        if (reached.contains(EncodeReached(nextPosition, current.Keys))) continue;

        var newPositions = new List<Point>.generate(0, (index) => Point.origin());
        for (var i = 0; i < current.Positions.length; i++)
          newPositions.add(i == robot ? nextPosition : current.Positions[i]);

        var newState = new StatePart2(newPositions,
            isKey(content) ? current.Keys | (1 << (content - a)) : current.Keys,
            current.Length + 1);

        if (newState.Keys == mostKeys && newState.Length < shortestPath) shortestPath = newState.Length;
        if (newState.Keys > mostKeys)
        {
          mostKeys = newState.Keys;
          shortestPath = newState.Length;
        }

        reached.add(EncodeReached(newState.Positions[robot], newState.Keys));
        frontier.add(newState);
      }
    }
  }

  return shortestPath;
}
