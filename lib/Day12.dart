

import 'dart:io';

var steps = 1000;

Future<void> day12() async {
  var file = File('input/Day12.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var moons = List<Moon>();
    for (var line in contents) {
      var allMatches = RegExp('(-?[0-9]+)').allMatches(line);
      var coordinates = allMatches.map((m) => int.parse(m.group(0))).toList();
      moons.add(Moon(coordinates[0], coordinates[1], coordinates[2]));
    }
    for (var i = 0; i < steps; i++) {
      simulate(moons);
    }
    var part1 = moons.fold(0, (p, c) => p + c.totalEnergy);
    print('Part 1: $part1');
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