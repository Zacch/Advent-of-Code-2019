import 'IntcodeComputer.dart';

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
