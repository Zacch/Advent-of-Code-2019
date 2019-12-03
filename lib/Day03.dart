

import 'dart:io';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
  Point.origin() { x = 0;  y = 0; }

  @override String toString() { return '($x, $y)'; }
}

class Rect {
  int bottom;
  int left;
  int top;
  int right;
  Rect(this.bottom, this.left, this.top, this.right);
  Rect.empty() { bottom = 0; left = 0; top = 0; right = 0; }

  int width() { return right - left; }
  int height() { return top - bottom; }

  @override String toString() {return 'Rect{($left, $bottom), ($right, $top)}';}
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


Future<void> day03() async {
  var file = File('input/Day03.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var bounds = getBounds(contents[0]);

    final size = 5;
    final grid = List<List<String>>.generate(bounds.height(),
            (i) => List<String>.generate(bounds.width(), (j) => (i * size + j).toString()));

    print(bounds);
    print(grid);

    print(grid[2][4]);
    var directions = contents[1].split(",");
    print(directions);
  }
}


