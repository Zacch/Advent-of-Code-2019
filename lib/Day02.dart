import 'dart:io';

Future<void> day02() async {
  var file = File('input/Day02.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s));
    print('Part 1: ${execute(List.from(startingMemory), 12, 02)}');

    for(int noun = 0; noun < 100; noun++) {
      for(int verb = 0; verb < 100; verb++) {
        if (execute(List.from(startingMemory), noun, verb) == 19690720) {
          print('Part 2: ${noun * 100 + verb}');
        }
      }
    }
  }
}

int execute(List<int> memory, int noun, int verb) {
  memory[1] = noun;
  memory[2] = verb;
  for (int index = 0; index < memory.length && memory[index]!=99; index += 4) {
    switch (memory[index]) {
      case 1:
        memory[memory[index + 3]] = memory[memory[index + 1]] + memory[memory[index + 2]];
        break;
      case 2:
        memory[memory[index + 3]] = memory[memory[index + 1]] * memory[memory[index + 2]];
        break;
      default:
        print("ERROR!");
    }
  }
  return memory[0];
}