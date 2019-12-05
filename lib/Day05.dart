import 'dart:io';

Future<void> day05() async {
  var file = File('input/Day05.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s)).toList();
    var computer = IntcodeComputer(startingMemory, [1]);
    computer.execute();
    print('Part 1: ${computer.output.last}');

    // Start over with input 5
    startingMemory = parts.map((s) => int.parse(s)).toList();
    computer = IntcodeComputer(startingMemory, [5]);
    computer.execute();
    print('Part 2: ${computer.output.first}');
  }
}

class IntcodeComputer {
  List<int> memory;
  int ip;
  List<int> input;
  List<int> output = [];
  bool isRunning;

  IntcodeComputer(this.memory, this.input);

  List<int> execute() {
    ip = 0;
    isRunning = true;
    while (isRunning) {
      var instruction = getNextInstruction();
      instruction.execute(this);
    }
    return output;
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
      case 99:
        instruction = Halt();
        break;
      default:
        print("ERROR!");
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

  setMemory(int position, int value) {
    memory[position] = value;
  }
}

abstract class Instruction {
  var modes = List<int>();
  var parameters = List<int>();

  void execute(IntcodeComputer state);

  // Loads parameters into the instruction and increments the instruction pointer
  void load(IntcodeComputer state, int parameterCount) {
    state.ip++;
    for(var i = 0; i < parameterCount; i++) {
      var parameter = state.memory[state.ip + i];
      switch (modes[i]) {
        case 0:
          parameters.add(state.memory[parameter]);
          break;
        case 1:
          parameters.add(parameter);
          break;
      }
    }
    state.ip += parameterCount;
  }
}

class Add extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    modes[2] = 1;
    load(state, 3);
    state.setMemory(parameters[2], parameters[0] + parameters[1]);
  }
}

class Multiply extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    modes[2] = 1;
    load(state, 3);
    state.setMemory(parameters[2], parameters[0] * parameters[1]);
  }
}

class Input extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    // We want the immediate argument here
    modes[0] = 1;
    load(state, 1);
    state.setMemory(parameters[0], state.input.removeAt(0));
  }
}

class Output extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    load(state, 1);
    state.output.add(parameters[0]);
  }
}

class Halt extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    load(state, 0);
    state.isRunning = false;
  }
}

class JumpIfTrue extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    load(state, 2);
    if (parameters[0] != 0) {
      state.ip = parameters[1];
    }
  }
}

class JumpIfFalse extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    load(state, 2);
    if (parameters[0] == 0) {
      state.ip = parameters[1];
    }
  }
}

class LessThan extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    modes[2] = 1;
    load(state, 3);
    state.setMemory(parameters[2], (parameters[0] < parameters[1]) ? 1 : 0);
  }
}

class Equal extends Instruction {
  @override
  void execute(IntcodeComputer state) {
    modes[2] = 1;
    load(state, 3);
    state.setMemory(parameters[2], (parameters[0] == parameters[1]) ? 1 : 0);
  }
}

