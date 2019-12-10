

import 'dart:io';

import 'Point.dart';
import 'Rect.dart';

class Grid {
  Rect bounds;
  List<List<String>> grid;

  Grid(Rect bounds) {
    this.bounds = bounds;
    grid = List<List<String>>.generate(bounds.height() + 1, (i) =>
    List<String>.generate(bounds.width() + 1, (j) => "."));
  }

  void set(Point p, String mark) {
    if (p.isInside(bounds)) {
      var y = p.y - bounds.bottom;
      var x = p.x - bounds.left;
      grid[y][x] = mark;
    }
  }

  String get(Point p) {
    if (p.isInside(bounds)) {
      var y = p.y - bounds.bottom;
      var x = p.x - bounds.left;
      return grid[y][x];
    }
    return "";
  }

  draw() {
    for (var row in grid.reversed) {
      var line = "";
      for (var col in row) {
        line += col;
      }
      print(line);
    }
  }
}

Rect getBounds(String content) {
  Rect bounds = Rect.empty();
  var directions = content.split(",");
  Point p = Point.origin();
  for (var dir in directions) {
    var distance = int.parse(dir.substring(1, dir.length));
    switch (dir[0]) {
      case "U":
        p.y += distance;
        if (p.y > bounds.top) {
          bounds.top = p.y;
        }
        break;
      case "L":
        p.x -= distance;
        if (p.x < bounds.left) {
          bounds.left = p.x;
        }
        break;
      case "D":
        p.y -= distance;
        if (p.y < bounds.bottom) {
          bounds.bottom = p.y;
        }
        break;
      case "R":
        p.x += distance;
        if (p.x > bounds.right) {
          bounds.right = p.x;
        }
        break;
    }
  }
  return bounds;
}

//---------------------

List<Point> crossings = List();

void drawPath(String path, Grid grid, List<Point> linePoints) {
  var directions = path.split(",");

  Point p = Point.origin();
  for (var dir in directions) {
    var distance = int.parse(dir.substring(1, dir.length));
    switch (dir[0]) {
      case "U":
        p = move(p, Point(0, 1), "|", distance, grid, linePoints);
        break;
      case "L":
        p = move(p, Point(-1, 0), "-", distance, grid, linePoints);
        break;
      case "D":
        p = move(p, Point(0, -1), "|", distance, grid, linePoints);
        break;
      case "R":
        p = move(p, Point(1, 0), "-", distance, grid, linePoints);
        break;
    }
    grid.set(p, "+");
  }
}


Point move(Point start, Point delta, String mark, int distance, Grid grid, List<Point> points) {
  Point p = start;
  for (int i = 0; i < distance; i++) {
    p += delta;
    points.add(p);
    var gridValue = grid.get(p);
    if (gridValue == "-" || gridValue == "|") {
      crossings.add(p);
      grid.set(p, "X");
    } else {
      grid.set(p, mark);
    }
  }
  return p;
}

Future<void> day03() async {
  var file = File('input/Day03.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var bounds = getBounds(contents[0]);
    bounds.grow(2);

    var grid = Grid(bounds);
    grid.set(Point.origin(), "O");

    var firstLine = List<Point>();
    drawPath(contents[0], grid, firstLine);
    crossings.clear();
    var secondLine = List<Point>();
    drawPath(contents[1], grid, secondLine);

    // Filter out crossings where the second line crossed itself
    crossings = crossings.where((crossing) => (firstLine.indexWhere((p) => p == crossing) > -1)).toList();
    crossings.sort((a, b) => a.manhattanDistanceFromOrigin().compareTo(b.manhattanDistanceFromOrigin()));
    print("Part 1: ${crossings[0].manhattanDistanceFromOrigin()}");

    var closest = firstLine.length + secondLine.length;
    for (var crossing in crossings) {
      var combinedSteps = firstLine.indexWhere((p) => p == crossing) + 1 +
                          secondLine.indexWhere((p) => p == crossing) + 1;
      if (combinedSteps < closest) {
        closest = combinedSteps;
      }
    }
    print("Part 2: $closest");
  }
}
