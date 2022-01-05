import 'dart:math';

import 'Rect.dart';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
  Point.origin() { x = 0;  y = 0; }

  static final ORIGIN = Point.origin();
  static final UP = Point(0, 1);
  static final DOWN = Point(0, -1);
  static final LEFT = Point(-1, 0);
  static final RIGHT = Point(1, 0);

  Point copy() {
    return Point(x, y);
  }

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

  List<Point> neighbours() {
    var result = new List<Point>.generate(0, (index) => Point.origin());
    result.add(this + UP);
    result.add(this + LEFT);
    result.add(this + RIGHT);
    result.add(this + DOWN);
    return result;
  }

  Point turnLeft() {
    return Point(-y, x);
  }

  Point turnRight() {
    return Point(y, -x);
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
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Point &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override String toString() { return '($x, $y)'; }
}

class Point3 {
  int x;
  int y;
  int z;

  Point3(this.x, this.y, this.z);

  Point3.from(Point p) { x = p.x; y = p.y; z = 0; }
  Point3.origin() { x = 0; y = 0; z = 0; }

  static final ORIGIN = Point3.origin();
  static final UP = Point3(0, 0, 1);
  static final DOWN = Point3(0, 0, -1);
  static final NORTH = Point3(0, 1, 0);
  static final SOUTH = Point3(0, -1, 0);
  static final EAST = Point3(1, 0, 0);
  static final WEST = Point3(-1, 0, 0);

  Point3 copy() {
    return Point3(x, y, z);
  }

  Point3 operator +(Point3 other) {
    return Point3(x + other.x, y + other.y, z + other.z);
  }

  Point toPoint() { return Point(x, y); }

  @override String toString() { return '($x, $y, $z)'; }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point3 && runtimeType == other.runtimeType && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}