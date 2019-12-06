import 'dart:io';

var orbits = Map<String, List<String>>();

Future<void> day06() async {
  var file = File('input/Day06.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();

    for (var string in contents) {
      var parts = string.split(')');
      if (orbits.containsKey(parts[0])) {
        orbits[parts[0]].add(parts[1]);
      } else {
        orbits[parts[0]] = [parts[1]];
      }
    }

    print('Part 1: ${countOrbits('COM', 0)}');
    print('Part 2: ${distanceBetween(findOrbited('YOU'), findOrbited('SAN'))}');
  }
}

int countOrbits(String object, int level) {
  if (!orbits.containsKey(object)) {
    return level;
  }
  int result = level;
  var orbitingObjects = orbits[object];
  orbitingObjects.forEach((o) => result += countOrbits(o, level + 1));
  return result;
}

String findOrbited(String object) {
  for (var key in orbits.keys) {
    if (orbits[key].contains(object)) {
      return key;
    }
  }
  return '';
}

int distanceBetween(String o1, o2) {
  return pathBetween(o1, o2, []).length - 1;
}

List<String> pathBetween(String object, goal, List<String> visited_in) {
  List<String> visited = [];
  visited.addAll(visited_in);
  visited.add(object);

  if (object == goal) {
    return visited;
  }

  List<String> candidates = [];
  var orbited = findOrbited(object);
  if (orbited.isNotEmpty) {
    candidates.add(orbited);
  }
  if (orbits.containsKey(object)) {
    candidates.addAll(orbits[object]);
  }
  candidates = candidates.where((o) => !visited.contains(o)).toList();

  for (var candidate in candidates) {
    var path = pathBetween(candidate, goal, visited);
    if (path.isNotEmpty) {
      return path;
    }
  }
  return [];
}