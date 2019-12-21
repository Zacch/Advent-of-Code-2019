
import 'dart:io';

import 'Grid.dart';
import 'Point.dart';
import 'Rect.dart';

var A = 'A'.codeUnitAt(0);
var Z = 'Z'.codeUnitAt(0);
var VOID = ' '.codeUnitAt(0);

Future<void> day20() async {
  var file = File('input/Day20.txt');

  if (await file.exists()) {
    var contents = await file.readAsLines();
    var h = contents.length;
    var w = contents[0].length;
    var grid = Grid(Rect(0, 0, h - 1, w - 1));
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

    var teleports = Map<String, List<Point>>();
    var ignoreLetterAt = List<Point>();
    for (p.y = 0; p.y < h; p.y++) {
      for (p.x = 0; p.x < w; p.x++) {
        var c = grid.getChar(p);
        if (isLetter(c) && !ignoreLetterAt.contains(p)) {
          var p2 = p + Point(0, 1);
          var c2 = grid.getChar(p2);
          var teleport = p + Point(0, 2);
          if (!teleport.isInside(grid.bounds) || grid.getChar(teleport) == VOID) {
            teleport = p + Point(0, -1);
          }
          if (!isLetter(c2)) {
            p2 = p + Point(1, 0);
            c2 = grid.getChar(p + Point(1, 0));
            teleport = p + Point(2, 0);
            if (!teleport.isInside(grid.bounds) || grid.getChar(teleport) == VOID) {
              teleport = p + Point(-1, 0);
            }
          }
          if (!isLetter(c2)) {
            print('ERROR at $p (${String.fromCharCode(c)})');
            return;
          }
          ignoreLetterAt.add(p2);
          var teleportName = String.fromCharCodes([c, c2]);
          print('Found ${teleportName} at $p');
          if (!teleports.containsKey(teleportName)) {
            teleports[teleportName] = List<Point>();
          }
          teleports[teleportName].add(teleport);
        }
      }
    }
    var start = teleports['AA'].first;
    var goal = teleports['ZZ'].first;
    teleports.remove('AA');
    teleports.remove('ZZ');
    print(teleports);
    print('Start $start, Goal $goal');
    var connections = Map<Point, Point>();
    for (var points in teleports.values) {
      connections[points[0]] = points[1];
      connections[points[1]] = points[0];
    }
    print(connections);
  }
}

bool isLetter(int c) {
  return c >= A && c <= Z;
}
