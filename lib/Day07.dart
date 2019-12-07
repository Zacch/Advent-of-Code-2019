import 'dart:io';

Future<void> day07() async {
  var file = File('input/Day07.txt');

  if (await file.exists()) {
    var contents = await file.readAsString();
    var parts = contents.split(',');
    var startingMemory = parts.map((s) => int.parse(s)).toList();

//    var c = IntcodeComputer(List<int>.from(startingMemory), []);
//    c.printProgram();

    var sequences = makeSequences([0, 1, 2, 3, 4]);
    int part1 = 0;
    for (var sequence in sequences) {
      var lastOutput = 0;
      for (var i = 0; i < 5; i++) {
        var computer = IntcodeComputer(List<int>.from(startingMemory), [sequence[i], lastOutput]);
        computer.execute();
        lastOutput = computer.output.first;
      }
      if (lastOutput > part1) {
        part1 = lastOutput;
      }
    }
    print('Part 1: $part1');

    int part2 = 0;
   for (var sequence in sequences) {
      var amplifiers = List<IntcodeComputer>();
      for (var i = 0; i < 5; i++) {
        amplifiers.add(IntcodeComputer(List<int>.from(startingMemory), [sequence[i] + 5]));
      }
      var lastOutput = runLoop(amplifiers);

      if (lastOutput > part2) {
        part2 = lastOutput;
      }
    }
    print('Part 2: $part2');
  }
}

int runLoop(List<IntcodeComputer> amplifiers) {
  var index = 0;
  var nextInput = [0];
  while (!amplifiers[index].isHalted) {
    nextInput = amplifiers[index].continueWithNewInput(nextInput);
    amplifiers[index].output = [];
    index = (index + 1) % 5;
  }
  return nextInput.first;
}


List<List<int>> makeSequences(List<int> numbers) {
  if (numbers.length == 1) {
    return [numbers];
  }

  List<List<int>> sequences = [];
  for (var index = 0; index < numbers.length; index++) {
    var numbersCopy = new List<int>.from(numbers);
    var number = numbersCopy.removeAt(index);
    var subsequences = makeSequences(numbersCopy);
    subsequences.forEach((s) => { s.insert(0, number) });
    sequences.addAll(subsequences);
  }
  return sequences;
}

class IntcodeComputer {
  List<int> memory;
  int ip = 0;
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

  setMemory(int position, int value) {
    memory[position] = value;
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

//////////////////////////////////////////////////////////////////////////////////////////////

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
          parameters.add(state.memory[parameter]);
          break;
        case 1:
          parameters.add(parameter);
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
    modes[2] = 1;
    load(state);
    state.setMemory(parameters[2], parameters[0] + parameters[1]);
  }
}

class Multiply extends Instruction {
  Multiply() {paramCount = 3;}
  @override
  void execute(IntcodeComputer state) {
    modes[2] = 1;
    load(state);
    state.setMemory(parameters[2], parameters[0] * parameters[1]);
  }
}

class Input extends Instruction {
  Input() {paramCount = 1;}
  @override
  void execute(IntcodeComputer state) {
    if (!state.isWaiting) {
      modes[0] = 1;
      load(state);
    }
    if (state.input.isEmpty) {
      state.isWaiting = true;
    } else {
      state.isWaiting = false;
      state.setMemory(parameters[0], state.input.removeAt(0));
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

class Halt extends Instruction {
  Halt() {paramCount = 0;}
  @override
  void execute(IntcodeComputer state) {
    load(state);
    state.isRunning = false;
    state.isHalted = true;
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
    modes[2] = 1;
    load(state);
    state.setMemory(parameters[2], (parameters[0] < parameters[1]) ? 1 : 0);
  }
}

class Equal extends Instruction {
  Equal() {paramCount = 3;}
  @override
  void execute(IntcodeComputer state) {
    modes[2] = 1;
    load(state);
    state.setMemory(parameters[2], (parameters[0] == parameters[1]) ? 1 : 0);
  }
}

