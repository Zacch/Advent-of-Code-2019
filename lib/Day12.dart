

import 'dart:io';

var steps = 1000;

Future<void> day12() async {
  var file = File('input/Day12.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var moons = List<Moon>();
    var xs = [0,0,0,0], ys = [0,0,0,0], zs = [0,0,0,0];
    for (var line in contents) {
      var allMatches = RegExp('(-?[0-9]+)').allMatches(line);
      var coordinates = allMatches.map((m) => int.parse(m.group(0))).toList();
      moons.add(Moon(coordinates[0], coordinates[1], coordinates[2]));
      xs.add(coordinates[0]); ys.add(coordinates[1]); zs.add(coordinates[2]);
    }
    for (var i = 0; i < steps; i++) {
      simulate(moons);
    }
    var part1 = moons.fold(0, (p, c) => p + c.totalEnergy);
    print('Part 1: $part1');

    var periodX = findPeriod(xs);
    var periodY = findPeriod(ys);
    var periodZ = findPeriod(zs);
    var periodXY = periodX * periodY ~/ periodX.gcd(periodY);
    var periodXYZ = periodXY * periodZ ~/ periodXY.gcd(periodZ);
    print('Part 2: ${periodXYZ}');
  }
}

void simulate(List<Moon> moons) {
  for (var i = 0; i < moons.length; i++) {
    for (var j = i + 1; j < moons.length; j++) {
      moons[i].applyGravity(moons[j]);
    }
  }
  for (var moon in moons) {
    moon.applyVelocity();
  }
}

class Moon {
  int x, y, z;
  int vx = 0, vy = 0, vz = 0;

  Moon(this.x, this.y, this.z);

  applyGravity(Moon o) {
    if (x < o.x) { vx++; o.vx--; }
    if (x > o.x) { vx--; o.vx++; }
    if (y < o.y) { vy++; o.vy--; }
    if (y > o.y) { vy--; o.vy++; }
    if (z < o.z) { vz++; o.vz--; }
    if (z > o.z) { vz--; o.vz++; }
  }

  void applyVelocity() {
    x += vx; y += vy; z += vz;
  }

  int get totalEnergy {
    return (x.abs() + y.abs() + z.abs()) * (vx.abs() + vy.abs() + vz.abs());
  }

  @override
  String toString() {
    return '\nMoon{x: $x, y: $y, z: $z, vx: $vx, vy: $vy, vz: $vz, energy $totalEnergy}';
  }
}

///////////////////////////////////////////////////////////
int findPeriod(List<int> vector) {
  var start = vector.toString();
  var iterations = 0;
  do {
    for (var i = 0; i < 4; i++) {
      for (var j = i + 1; j < 4; j++) {
        if (vector[i + 4] < vector[j + 4]) { vector[i]++; vector[j]--; }
        if (vector[i + 4] > vector[j + 4]) { vector[i]--; vector[j]++; }
      }
    }
    for (var i = 0; i < 4; i++) { vector[i + 4] += vector[i]; }
    iterations++;
    if (vector.toString() == start) {
      return iterations;
    }

  } while (true);
}
