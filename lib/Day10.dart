
import 'dart:io';

import 'dart:math';
import 'Point.dart';

var space = List<List<bool>>();
int get height { return space.length; }
int get width { return space[0].length; }

Future<void> day10() async {
  var file = File('input/Day10.txt');
  var asteroid_rune = "#".codeUnitAt(0);

  if (await file.exists()) {
    var contents = await file.readAsLines();
    for (var line in contents) {
      space.add(line.runes.map((rune) => rune == asteroid_rune).toList());
    }

    var bestAsteroid = Point.origin();
    var visibleAsteroids = List<Point>();
    for(var y = 0; y < height; y++) {
      for(var x = 0; x < width; x++) {
        var visible = visibleAsteroidsFrom(x, y);
        if (visible.length > visibleAsteroids.length) {
          bestAsteroid = Point(x, y);
          visibleAsteroids = visible;
        }
      }
    }
    print('Part 1: ${visibleAsteroids.length}');

    var asteroidsLocal = visibleAsteroids.map((p) => p - bestAsteroid).toList();
    asteroidsLocal.sort((p1, p2) => p1.compassAngle < p2.compassAngle ? -1: 1);
    var lucky200 = asteroidsLocal[199] + bestAsteroid;
    print('Part 2: ${lucky200.x * 100 + lucky200.y}');
  }
}

List<Point> visibleAsteroidsFrom(int x, int y) {
  if (!space[y][x]) {
    return [];
  }
  var result = List<Point>();
  for(var y1 = 0; y1 < height; y1++) {
    for(var x1 = 0; x1 < width; x1++) {
      if (space[y1][x1] && lineOfSight(x, y, x1, y1)) {
        result.add(Point(x1, y1));
      }
    }
  }
  return result;
}

bool lineOfSight(int x0, int y0, int x1, int y1) {
  if (x0 == x1 && y0 == y1) { return false; }
  if (x0 == x1) {
    for (int y = min(y0, y1) + 1; y < max(y0, y1); y++) {
      if (space[y][x0]) {
        return false;
      }
    }
    return true;
  }
  var deltaY =  (y1 - y0) / (x1 - x0);
  var y = ((x0 < x1) ? y0: y1).toDouble();
  for (int x = min(x0, x1) + 1; x < max(x0, x1); x++) {
    y += deltaY;
    if ((y - y.round()).abs() < 0.000001) {
      if (space[y.round()][x]) {
        return false;
      }
    }
  }
  return true;
}