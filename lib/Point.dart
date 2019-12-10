import 'dart:math';

import 'Rect.dart';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
  Point.origin() { x = 0;  y = 0; }

  Point operator +(Point other) {
    return Point(x + other.x, y + other.y);
  }

  Point operator -(Point other) {
    return Point(x - other.x, y - other.y);
  }

  bool isInside(Rect r) {
    return x >= r.left && x <= r.right && y >= r.bottom && y <= r.top;
  }

  int manhattanDistanceFromOrigin() {
    return x.abs() + y.abs();
  }

  /// Returns the angle from the origin to the point in radians, twisted so that
  /// points on the positive Y axis (north) have angle 0,
  /// points on the positive X axis (east) have angle pi / 2
  /// points on the negative Y axis (south) have angle pi,
  /// points on the negative X axis (west) have angle 3 * pi / 2
  double get compassAngle {
    if (x == 0) {
      return y < 0 ? 0 : pi;
    }
    var value = atan2(y, x) + (pi / 2);
    return value < 0 ? value + 2 * pi : value;
  }

  @override
  bool operator ==(other) {
    if (other.runtimeType == Point) {
      var p = other as Point;
      return x == p.x && y == p.y;
    }
    return false;
  }

  @override String toString() { return '($x, $y)'; }
}
