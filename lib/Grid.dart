import 'Rect.dart';
import 'Point.dart';

class Grid {
  Rect bounds;
  List<List<String>> grid;
  int get height { return bounds.height(); }
  int get width { return bounds.width(); }

  Grid(Rect bounds, [String content]) {
    this.bounds = bounds;
    grid = List<List<String>>.generate(bounds.height() + 1, (i) =>
            List<String>.generate(bounds.width() + 1, (j) => content ?? " "));
  }
  Grid copy() {
    var copy = Grid(bounds);
    copy.grid = List<List<String>>.from(grid);
    return copy;
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

  int getChar(Point p) {
    if (p.isInside(bounds)) {
      var y = p.y - bounds.bottom;
      var x = p.x - bounds.left;
      return grid[y][x].codeUnitAt(0);
    }
    return -1;
  }

  draw() {
    for (var row in grid) {
      var line = "";
      for (var col in row) {
        line += col;
      }
      print(line);
    }
  }
}
