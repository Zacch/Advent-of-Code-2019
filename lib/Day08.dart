import 'dart:io';

const layerLength = 150;

Future<void> day08() async {
  var file = File('input/Day08.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var allMatches = RegExp(".{$layerLength}").allMatches(contents);
    var layers = allMatches.map((m) => m.group(0));
    var fewestZeroesSoFar = 99999;
    var part1 = 0;
    for (var layer in layers) {
      int zeroes = RegExp("(0)").allMatches(layer).length;
      if (zeroes < fewestZeroesSoFar) {
        int ones = RegExp("(1)").allMatches(layer).length;
        int twos = RegExp("(2)").allMatches(layer).length;
        part1 = ones * twos;
        fewestZeroesSoFar = zeroes;
      }
    }
    print('Part 1: $part1');

    var image = layers.first;
    for (var layer in layers) {
      for (int i = 0; i < layerLength; i++) {
        if (image[i] == '2') {
          image = image.substring(0, i) + layer[i] + image.substring(i + 1);
        }
      }
    }
    image = image.replaceAll('0', ' ');
    var lines = RegExp(".{25}").allMatches(image);
    print('\nPart 2:');
    lines.forEach((l) => print('        ${l.group(0)}'));
  }
}
