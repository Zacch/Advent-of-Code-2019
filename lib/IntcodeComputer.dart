import 'IntcodeInstruction.dart';

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
