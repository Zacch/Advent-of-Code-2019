import 'dart:io';
import 'Point.dart';

Future<void> day11() async {
  var file = File('input/Day11.txt');
  var hull = Map<Point, bool>();

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s)).toList();

    //  var c = IntcodeComputer(List<int>.from(startingMemory), []);
    //  c.printProgram();

    var computer = IntcodeComputer(List<int>.from(startingMemory), [0]);
    var paintBot = PaintBot(computer);
    paintBot.run(hull);

    print('Part 1: ${hull.length}');

    hull.clear();
    hull[Point.origin()] = true;
    computer = IntcodeComputer(List<int>.from(startingMemory), [1]);
    paintBot = PaintBot(computer);
    paintBot.run(hull);

    print('Part 2:');
    printHull(hull);
  }
}

void printHull(Map<Point, bool> hull) {
  var low = Point.origin();
  var high = Point.origin();
  for (var p in hull.keys) {
    if (p.x < low.x) { low.x = p.x; }
    if (p.y < low.y) { low.y = p.y; }
    if (p.x > high.x) { high.x = p.x; }
    if (p.y > high.y) { high.y = p.y; }
  }
  for (int row = high.y; row >= low.y; row--) {
    var line = "";
    for (int col = low.x; col <= high.x; col++) {
      line += hull[Point(col, row)] ?? false ? "#" : " ";
    }
    print(line);
  }
}

class PaintBot {
  var position = Point.origin();
  var direction = 0;
  IntcodeComputer computer;

  PaintBot(this.computer);

  void run(Map<Point, bool> hull) {
    computer.execute();
    while (!computer.isHalted) {
      hull[position] = (computer.output[0] != 0);
      turn(computer.output[1]);
      move();
      computer.output.clear();
      var newInput = (hull[position] ?? false) ? 1 : 0;
      computer.continueWithNewInput([newInput]);
    }
  }

  void turn(int output) {
    var relativeDirection = (output == 1 ? 1 : -1);
    direction = (direction + relativeDirection) % 4;
  }

  void move() {
    switch (direction) {
      case 0: // up
        position += Point(0, 1);
        break;
      case 1: // right
        position += Point(1, 0);
        break;
      case 2: // down
        position += Point(0, -1);
        break;
      case 3: // left
        position += Point(-1, 0);
        break;
    }
  }
}

////////////////////////////////////////////////////////////////////////////
class IntcodeComputer {
  List<int> memory;
  var bigMemory = Map<int, int>();
  int ip = 0;
  int relativeBase = 0;
  List<int> input;
  List<int> output = [];
  Instruction currentInstruction = Halt();
  bool isRunning = false;
  bool isWaiting = false;
  bool isHalted = false;

  IntcodeComputer(this.memory, this.input);

  List<int> execute() {
    ip = 0;
    isRunning = true;
    isWaiting = false;
    isHalted = false;
    currentInstruction = getNextInstruction();
    return run();
  }

  List<int> run() {
    while (isRunning) {
      currentInstruction.execute(this);
      if (isWaiting || isHalted) {
        return output;
      }
      currentInstruction = getNextInstruction();
    }
    return output;
  }

  List<int> continueWithNewInput(List<int> newInput) {
    input.addAll(newInput);
    if (isWaiting) {
      return run();
    } else {
      return execute();
    }
  }

  Instruction getNextInstruction() {
    var value = memory[ip];
    var opcode = value % 100;
    Instruction instruction;
    switch (opcode) {
      case 1:
        instruction = Add();
        break;
      case 2:
        instruction = Multiply();
        break;
      case 3:
        instruction = Input();
        break;
      case 4:
        instruction = Output();
        break;
      case 5:
        instruction = JumpIfTrue();
        break;
      case 6:
        instruction = JumpIfFalse();
        break;
      case 7:
        instruction = LessThan();
        break;
      case 8:
        instruction = Equal();
        break;
      case 9:
        instruction = SetBase();
        break;
      case 99:
        instruction = Halt();
        break;
      default:
        throw Exception;
    }
    int rest = value ~/ 100;
    while (rest > 0) {
      instruction.modes.add(rest % 10);
      rest ~/= 10;
    }
    while (instruction.modes.length < 3) {
      instruction.modes.add(0);
    }
    return instruction;
  }

  setMemory(int position, int mode, int value) {
    if (mode == 2) {
      position += relativeBase;
    }
    if (position < memory.length) {
      memory[position] = value;
    } else {
      bigMemory[position] = value;
    }
  }

  int getMemory(int position, int mode) {
    if (mode == 2) {
      position += relativeBase;
    }
    if (position < memory.length) {
      return memory[position];
    } else {
      return bigMemory[position] ?? 0;
    }
  }

  @override
  String toString() {
    return 'IntcodeComputer{ip: $ip, r: $isRunning, '
        'w: $isWaiting, h: $isHalted, in $input, out $output, mem $memory}';
  }

  void printProgram() {
    var oldIp = ip;
    ip = 0;
    while(ip < memory.length) {
      try {
        var instrIp = ip;
        var instruction = getNextInstruction();
        ip++;
        var line = '$instrIp: ${instruction.runtimeType} ';
        for (int i = 0; i < instruction.paramCount; i++) {
          if (instruction.modes[i] == 0) {
            line += "\$";
          } else if (instruction.modes[i] == 2) {
            line += "r";
          }
          line += memory[ip + i].toString();
          if (i < instruction.paramCount - 1) {
            line += ', ';
          }
        }
        print(line);
        ip += instruction.paramCount;
      } catch(e) {
        print('$ip: -- ${memory[ip]}');
        ip++;
      }
    }
    ip = oldIp;
  }
}

////////////////////////////////////////////////////////////////////////////////

abstract class Instruction {
  var modes = List<int>();
  var parameters = List<int>();
  var paramCount = 0;
  void execute(IntcodeComputer state);

  // Loads parameters into the instruction and increments the instruction pointer
  void load(IntcodeComputer state) {
    state.ip++;
    for(var i = 0; i < paramCount; i++) {
      var parameter = state.memory[state.ip + i];
      switch (modes[i]) {
        case 0:
          parameters.add(state.getMemory(parameter, 0));
          break;
        case 1:
          parameters.add(parameter);
          break;
        case 2:
          parameters.add(state.getMemory(parameter, 2));
          break;
      }
    }
    state.ip += paramCount;
  }

  @override
  String toString() {
    return '${this.runtimeType}\t $parameters, modes: $modes}';
  }
}

class Add extends Instruction {
  Add() {paramCount = 3;}
  @override
  void execute(IntcodeComputer state) {
    var oldMode = modes[2];
    modes[2] = 1;
    load(state);
    modes[2] = oldMode;

    state.setMemory(parameters[2], modes[2], parameters[0] + parameters[1]);
  }
}

class Multiply extends Instruction {
  Multiply() {paramCount = 3;}
  @override
  void execute(IntcodeComputer state) {
    var oldMode = modes[2];
    modes[2] = 1;
    load(state);
    modes[2] = oldMode;
    state.setMemory(parameters[2], modes[2], parameters[0] * parameters[1]);
  }
}

class Input extends Instruction {
  Input() {paramCount = 1;}
  @override
  void execute(IntcodeComputer state) {
    if (!state.isWaiting) {
      var oldMode = modes[0];
      modes[0] = 1;
      load(state);
      modes[0] = oldMode;
    }
    if (state.input.isEmpty) {
      state.isWaiting = true;
    } else {
      state.isWaiting = false;
      state.setMemory(parameters[0], modes[0], state.input.removeAt(0));
    }
  }
}

class Output extends Instruction {
  Output() {paramCount = 1;}
  @override
  void execute(IntcodeComputer state) {
    load(state);
    state.output.add(parameters[0]);
  }
}

class JumpIfTrue extends Instruction {
  JumpIfTrue() {paramCount = 2;}
  @override
  void execute(IntcodeComputer state) {
    load(state);
    if (parameters[0] != 0) {
      state.ip = parameters[1];
    }
  }
}

class JumpIfFalse extends Instruction {
  JumpIfFalse() {paramCount = 2;}
  @override
  void execute(IntcodeComputer state) {
    load(state);
    if (parameters[0] == 0) {
      state.ip = parameters[1];
    }
  }
}

class LessThan extends Instruction {
  LessThan() {paramCount = 3;}
  @override
  void execute(IntcodeComputer state) {
    var oldMode = modes[2];
    modes[2] = 1;
    load(state);
    modes[2] = oldMode;
    state.setMemory(parameters[2], modes[2], (parameters[0] < parameters[1]) ? 1 : 0);
  }
}

class Equal extends Instruction {
  Equal() {paramCount = 3;}
  @override
  void execute(IntcodeComputer state) {
    var oldMode = modes[2];
    modes[2] = 1;
    load(state);
    modes[2] = oldMode;
    state.setMemory(parameters[2], modes[2], (parameters[0] == parameters[1]) ? 1 : 0);
  }
}

class SetBase extends Instruction {
  SetBase() {paramCount = 1;}
  @override
  void execute(IntcodeComputer state) {
    load(state);
    state.relativeBase += parameters[0];
  }
}

class Halt extends Instruction {
  Halt() {paramCount = 0;}
  @override
  void execute(IntcodeComputer state) {
    load(state);
    state.isRunning = false;
    state.isHalted = true;
  }
}
