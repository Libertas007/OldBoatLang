import 'dart:io';

Map<String, double> barrels = {};
Map<String, String> packages = {};
int linePointer = 0;
bool started = false;
List<CodeBlockData> blocks = [];

void main(List<String> args) {
  if (args.length == 0) {
    while (true) {
      stdout.write("BoatLang terminal > ");
      String? input = stdin.readLineSync();

      if (input == null) input = "";
      if (input == "") continue;
      print("-> " + executeExpression(input));
    }
  } else {
    String file = readFileSync(args[0]);
    List<String> lines = file.split("\n");

    for (linePointer = 0; linePointer < lines.length; linePointer++) {
      String line = lines[linePointer].trim();

      executeExpression(line);
    }
  }
}

String executeExpression(String line) {
  List<String> args = line.trim().split(" ");
  final String command = args[0];
  if (args.length == 0 || line.trim().isEmpty || line.trim().startsWith("//"))
    return "";

  if (command == "SAIL" && !started) return executeSail(args);

  if (started)
    switch (command) {
      case "ADD":
        return executeAdd(args);
      case "ARRIVE":
        return executeArrive(args);
      case "BROADCAST":
        return executeBroadcast(args);
      case "CRASH":
        return executeCrash(args);
      case "DIVIDE":
        return executeDivide(args);
      case "DROP":
        return executeDrop(args);
      case "END":
        return executeEnd(args);
      case "LISTEN":
        return executeListen(args);
      case "LOOP":
        return executeLoop(args);
      case "MULTIPLY":
        return executeMultiply(args);
      case "REPACK":
        return executeRepack(args);
      case "REQUEST":
        return executeRequest(args);
      case "RETURN":
        return executeReturn(args);
      case "SET":
        return executeSet(args);
      case "SINK":
        return executeSink(args);
      case "SUBTRACT":
        return executeSubtract(args);
      default:
        return error("Unknown command");
    }
  return error("'SAIL' must be the first command!");
}

// Syntax: ADD [BARREL] TO [BARREL]
String executeAdd(List<String> args) {
  if (args.length != 4 || args[2] != "TO") {
    return error("Invalid syntax");
  }

  double? toAdd = double.tryParse(args[1]);
  if (toAdd == null) {
    if (barrels.containsKey(args[1])) {
      toAdd = barrels[args[1]];
    } else {
      return error("'ADD' must be followed by another variable or BARREL");
    }
  }

  if (barrels.containsKey(args[3])) {
    barrels[args[3]] = barrels[args[3]]! + toAdd!;
    return "${barrels[args[3]]}";
  } else {
    return error("Variable ${args[3]} is not defined or is not BARREL!");
  }
}

// Syntax: ARRIVE AT [PACKAGE]
String executeArrive(List<String> args) {
  if (args.length < 3 || args[1] != "AT") {
    return error("Invalid syntax!");
  }

  return exit(0);
}

// Syntax: BROADCAST [BARREL|PACKAGE]
String executeBroadcast(List<String> args) {
  if (args.length == 1) {
    return error("Invalid syntax");
  }

  if (!args[1].startsWith("\"") && !args[1].endsWith("\"")) {
    String toPrint = packages[args[1]] ?? barrels[args[1]].toString();
    toPrint = toPrint
        .replaceAll("true", "YES")
        .replaceAll("false", "NO")
        .replaceAll("null", "EMPTY");
    print(toPrint);
    return "\"$toPrint\"";
  }

  print(args.sublist(1).join(" ").split("\"")[1]);
  return args.sublist(1).join(" ").split("\"")[1];
}

// Syntax: CRASH INTO [PACKAGE]
String executeCrash(List<String> args) {
  if (args.length < 3 || args[1] != "INTO") {
    return error("Invalid syntax");
  }

  return exit(1);
}

// Syntax: DIVIDE [BARREL] BY [BARREL]
String executeDivide(List<String> args) {
  if (args.length != 4 || args[2] != "BY") {
    return error("Invalid syntax");
  }

  double? toDivide = double.tryParse(args[3]);
  if (toDivide == null) {
    if (barrels.containsKey(args[3])) {
      toDivide = barrels[args[3]];
    } else {
      return error("'BY' must be followed by another variable or BARREL");
    }
  }

  if (barrels.containsKey(args[1])) {
    barrels[args[1]] = barrels[args[1]]! / toDivide!;
    return "${barrels[args[1]]}";
  } else {
    return error("Variable ${args[1]} is not defined or is not BARREL!");
  }
}

// Syntax: DROP [BARREL|PACKAGE]
String executeDrop(List<String> args) {
  if (args.length != 2) {
    return error("Invalid syntax");
  }

  if (packages.containsKey(args[1])) {
    packages.remove(args[1]);
  }

  if (barrels.containsKey(args[1])) {
    barrels.remove(args[1]);
  }

  return "";
}

// Syntax: END
String executeEnd(List<String> args) {
  if (args.length != 1) {
    return error("Invalid syntax!");
  }

  CodeBlockData last = blocks.last;

  if (last.type == CodeBlockType.If) {
    blocks.removeLast();
    return "";
  }

  if (last.type == CodeBlockType.Loop) {
    if (last.iterationsLeft == 0) {
      blocks.removeLast();
      return "";
    }

    blocks[blocks.length - 1].iterationsLeft--;
    linePointer = last.start;
    if (last.iterationVar != "")
      barrels[last.iterationVar] = barrels[last.iterationVar]! + 1;
    return "";
  }

  return "";
}

// Syntax: LISTEN ON [PACKAGE]
String executeListen(List<String> args) {
  if (args.length != 3) {
    return error("Invalid syntax");
  }

  if (!packages.containsKey(args[2])) {
    return error("Variable ${args[2]} is not defined or is not PACKAGE!");
  }

  String input = stdin.readLineSync() ?? "";

  packages[args[2]] = input;

  return "\"$input\"";
}

// Syntax: LOOP [BARREL] TIMES: ... END
String executeLoop(List<String> args) {
  if (args.length < 3 ||
      !args[2].startsWith("TIMES") ||
      !args.last.endsWith(":")) {
    return error("Invalid syntax");
  }

  double? iterations = double.tryParse(args[1]);
  if (iterations == null) {
    if (barrels.containsKey(args[1])) {
      iterations = barrels[args[1]];
    } else {
      return error("'LOOP' must be followed by another variable or BARREL");
    }
  }

  CodeBlockData toAdd = CodeBlockData(
    start: linePointer,
    type: CodeBlockType.Loop,
    iterationsLeft: iterations!.ceil() - 1,
  );

  if (args.length == 5 && args[3] == "AS") {
    createBarrel(args[4].replaceAll(":", ""), 0);
    toAdd.iterationVar = args[4].replaceAll(":", "");
  }

  blocks.add(toAdd);
  return "";
}

// Syntax: IF {CONDITION}: ... END
String executeIf(List<String> args) {
  if (args.length < 4 || !args.last.endsWith(":")) {
    return error("Invalid syntax");
  }
  return "";
}

// Syntax: MULTIPLY [BARREL] BY [BARREL]
String executeMultiply(List<String> args) {
  if (args.length != 4 || args[2] != "BY") {
    return error("Invalid syntax");
  }

  double? toMultiply = double.tryParse(args[3]);
  if (toMultiply == null) {
    if (barrels.containsKey(args[3])) {
      toMultiply = barrels[args[3]];
    } else {
      return error("'BY' must be followed by another variable or BARREL");
    }
  }

  if (barrels.containsKey(args[1])) {
    barrels[args[1]] = barrels[args[1]]! * toMultiply!;
    return "${barrels[args[1]]}";
  } else {
    return error("Variable ${args[1]} is not defined or is not BARREL!");
  }
}

// Syntax: REPACK [BARREL|PACKAGE] TO (BARREL|PACKAGE)
String executeRepack(List<String> args) {
  if (args.length != 4 || args[2] != "TO") {
    return error("Invalid syntax");
  }

  if (barrels.containsKey(args[1])) {
    if (args[3] == "PACKAGE") {
      String value = barrels[args[1]].toString();

      barrels.remove(args[1]);
      createPackage(args[1], value);
      return '';
    }
    return "";
  }

  if (packages.containsKey(args[1])) {
    if (args[3] == "BARREL") {
      double? value = double.tryParse(packages[args[1]] ?? "");

      if (value == null) {
        error("Cannot convert ${packages[args[1]]} to BARREL!");
        return '';
      }

      packages.remove(args[1]);
      createBarrel(args[1], value);
      return '';
    }
    return "";
  }

  error("Variable ${args[1]} is not defined");
  return "";
}

// Syntax: REQUEST (BARREL|PACKAGE) [PACKAGE]
String executeRequest(List<String> args) {
  if (args.length != 3) {
    return error("Invalid syntax");
  }

  if (args[1] == "BARREL") {
    createBarrel(args[2], 0);
    return "0";
  }

  if (args[1] == "PACKAGE") {
    createPackage(args[2], "");
    return "\"\"";
  }

  error("Invalid syntax");
  return "";
}

// Syntax: RETURN [BARREL|PACKAGE]
String executeReturn(List<String> args) {
  if (args.length != 2) {
    return error("Invalid syntax");
  }

  if (packages.containsKey(args[1])) {
    packages.remove(args[1]);
  }

  if (barrels.containsKey(args[1])) {
    barrels.remove(args[1]);
  }

  return "";
}

// Syntax: SAIL ON [PACKAGE]
String executeSail(List<String> args) {
  if (args.length != 3 || args[1] != "ON") {
    return error("Invalid syntax");
  }
  started = true;
  return "";
}

// Syntax: REPACK [BARREL|PACKAGE] TO (BARREL|PACKAGE)
String executeSet(List<String> args) {
  if (args.length < 4 || args[2] != "TO") {
    return error("Invalid syntax");
  }

  if (barrels.containsKey(args[1])) {
    double? toSet = double.tryParse(args[3]);
    if (barrels.containsKey(args[3])) toSet = barrels[args[3]];

    if (toSet == null)
      return error("'${args[3]}' cannot be assigned to BARREL!");
    barrels[args[1]] = toSet;
    return toSet.toString();
  }

  if (packages.containsKey(args[1])) {
    String toSet = "";
    if (packages.containsKey(args[3]))
      toSet = packages[args[3]] ?? "";
    else
      toSet = args.sublist(3).join(" ").split("\"")[1];

    packages[args[1]] = toSet;
    return "\"$toSet\"";
  }

  error("Variable ${args[1]} is not defined");
  return "";
}

// Syntax: SINK
String executeSink(List<String> args) {
  return exit(1);
}

// Syntax: SUBTRACT [BARREL] FROM [BARREL]
String executeSubtract(List<String> args) {
  if (args.length != 4 || args[2] != "FROM") {
    return error("Invalid syntax");
  }

  double? toSubtract = double.tryParse(args[1]);
  if (toSubtract == null) {
    if (barrels.containsKey(args[1])) {
      toSubtract = barrels[args[1]];
    } else {
      return error("'SUBTRACT' must be followed by another variable or BARREL");
    }
  }

  if (barrels.containsKey(args[3])) {
    barrels[args[3]] = barrels[args[3]]! - toSubtract!;
    return "${barrels[args[3]]}";
  } else {
    return error("Variable ${args[3]} is not defined or is not BARREL!");
  }
}

void createBarrel(String name, double value) {
  if (barrels.containsKey(name) || packages.containsKey(name)) {
    error("Variable already exists");
  }

  barrels.addEntries([MapEntry(name, value)]);
}

void createPackage(String name, String value) {
  if (barrels.containsKey(name) || packages.containsKey(name)) {
    error("Variable already exists");
  }

  packages.addEntries([MapEntry(name, value)]);
}

bool evaluateExpression(List<String> args) {
  dynamic previous;
  bool stringConstruction = false;
  Type expect = String;

  for (var i = 0; i < args.length; i++) {
    final String element = args[i];

    if (element.startsWith("\"")) {
      previous = element.replaceAll("\"", "");
      stringConstruction = true;
      continue;
    }

    if (element.endsWith("\"")) {
      previous += element.replaceAll("\"", "");
      stringConstruction = false;
      continue;
    }

    if (stringConstruction) {
      previous += element.replaceAll("\"", "");
      continue;
    }
  }

  return false;
}

String error(String text) {
  print("Error on line $linePointer: $text");
  return exit(1);
}

String readFileSync(String file) {
  return new File(file).readAsStringSync();
}

class CodeBlockData {
  int start;
  CodeBlockType type;
  int iterationsLeft;
  String iterationVar;

  CodeBlockData({
    required int this.start,
    required CodeBlockType this.type,
    int this.iterationsLeft = 0,
    String this.iterationVar = "",
  }) {}
}

enum CodeBlockType {
  Loop,
  If,
  While,
}
