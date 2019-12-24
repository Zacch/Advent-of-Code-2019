import 'dart:collection';
import 'dart:io';

import 'Grid.dart';
import 'Point.dart';
import 'Rect.dart';

var BUG = '#';
var EMPTY = '.';

var ratings = SplayTreeSet<int>();

Future<void> day24() async {
  var file = File('input/Day24.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var height = contents.length;
    var width = contents[0].length;
    var grid = Grid(Rect(0, 0, height, width));
    var p = Point(0, 0);
    for (var line in contents) {
      line.codeUnits.forEach((c) {
        grid.set(p, String.fromCharCode(c));
        p.x++;
      });
      p.y++;
      p.x = 0;
    }
    grid.draw();

    while (true) {
      var rating = biodiversityRating(grid);
      if (ratings.contains(rating)) {
        print('Part 1: $rating');
        break;
      }
      ratings.add(rating);
      grid = evolve(grid);
    }
  }

  var neighbors = make3dNeighbors();
  for (int i = 0; i < 25; i++) {
    print('$i: ${neighbors[i]}');
  }

}

List<List<Point3>> make3dNeighbors() {
  final CENTER = Point3(2, 2, 0);
  var allNeighbors = List<List<Point3>>();
  for (int i = 0; i < 25; i++) {
    var x = i % 5, y = i ~/ 5;
    var neighbors = List<Point3>();
    if (x > 0) neighbors.add(Point3(x - 1, y, 0));
    if (x < 4) neighbors.add(Point3(x + 1, y, 0));
    if (y > 0) neighbors.add(Point3(x, y - 1, 0));
    if (y < 4) neighbors.add(Point3(x, y + 1, 0));
    if (x == 0) neighbors.add(Point3(1, 2, -1));
    if (x == 4) neighbors.add(Point3(3, 2, -1));
    if (y == 0) neighbors.add(Point3(2, 1, -1));
    if (y == 4) neighbors.add(Point3(2, 3, -1));
    neighbors.remove(CENTER);
    if (i == 7) {
      neighbors.addAll([Point3(0, 0, 1), Point3(1, 0, 1), Point3(2, 0, 1), Point3(3, 0, 1), Point3(4, 0, 1)]);
    }
    if (i == 11) {
      neighbors.addAll([Point3(0, 0, 1), Point3(0, 1, 1), Point3(0, 2, 1), Point3(0, 3, 1), Point3(0, 4, 1)]);
    }
    if (i == 13) {
      neighbors.addAll([Point3(4, 0, 1), Point3(4, 1, 1), Point3(4, 2, 1), Point3(4, 3, 1), Point3(4, 4, 1)]);
    }
    if (i == 17) {
      neighbors.addAll([Point3(0, 4, 1), Point3(1, 4, 1), Point3(2, 4, 1), Point3(3, 4, 1), Point3(4, 4, 1)]);
    }
    allNeighbors.add(neighbors);
  }
  return allNeighbors;
}

int biodiversityRating(Grid grid) {
  var rating = 0;
  var factor = 1;
  var p = Point.origin();
  for (int y = 0; y < grid.height; y++) {
    for (int x = 0; x < grid.width; x++) {
      if (grid.get(Point(x, y)) == BUG) {
        rating += factor;
      }
      factor *= 2;
    }
  }
  return rating;
}

Grid evolve(Grid oldGrid) {
  var newGrid = Grid(oldGrid.bounds);
  for (int y = 0; y < oldGrid.height; y++) {
    for (int x = 0; x < oldGrid.width; x++) {
      var p = Point(x, y);
      var neighbors = 0;
      if (x > 0 && oldGrid.get(p + Point.LEFT) == BUG) neighbors++;
      if (y > 0 && oldGrid.get(p + Point.DOWN) == BUG) neighbors++;
      if (x + 1 < oldGrid.width && oldGrid.get(p + Point.RIGHT) == BUG) neighbors++;
      if (y + 1 < oldGrid.height && oldGrid.get(p + Point.UP) == BUG) neighbors++;
      if (oldGrid.get(p) == BUG && neighbors == 1 ||
          oldGrid.get(p) == EMPTY && (neighbors == 1 || neighbors == 2)) {
        newGrid.set(p, BUG);
      } else {
        newGrid.set(p, EMPTY);
      }
    }
  }
  return newGrid;
}