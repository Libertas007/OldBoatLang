import 'dart:io';

import 'lexer.dart';
import 'scheduler.dart';

Map<String, double> barrels = {};
Map<String, String> packages = {};
int linePointer = 0;
bool started = false;
List<CodeBlockData> blocks = [];
final String TEMPLATE =
    "SAIL ON yacht\n\n// Here comes your code\n// Remove comment below to see \"Hello world!\" program\n// BROADCAST \"Hello world!\"\n\nARRIVE AT port";

void main(List<String> args) {
  if (args.length == 0) {
    print("Using version 'v1.1'");
    print("Welcome to terminal for Boat! Start typing some Boat commands!");
    while (true) {
      started = true;
      stdout.write("Boat terminal > ");
      String? input = stdin.readLineSync();

      if (input == null) input = "";
      if (input == "") continue;
      final Lexer lexer = Lexer(input);
      final Scheduler scheduler = Scheduler(lexer.tokens);

      print("-> " + executeExpression(scheduler.tasks[0]));
    }
  } else if (args.length == 1) {
    String file = readFileSync(args[0]);

    Lexer lexer = Lexer(file);

    Scheduler scheduler = Scheduler(lexer.tokens);

    scheduler.tasks.forEach((task) {
      if (task.tokens.length != 0) {
        executeExpression(task);
      }
    });
  } else {
    switch (args[0]) {
      case "new":
        createNew(args);
        break;
    }
  }
}

void createNew(List<String> args) {
  print("Creating new project from default template...");
  final String fileName = args[1];
  final File file =
      File(fileName.endsWith(".boat") ? fileName : fileName + ".boat");

  if (file.existsSync()) {
    stdout.write(
        "File '${fileName.endsWith(".boat") ? fileName : fileName + ".boat"}' already exists. Running 'boat new' will overwrite it. Do you want to continue? (y/N) ");
    String answer = stdin.readLineSync() ?? "n";
    if (answer.toLowerCase() != "y") {
      print("Aborting action...");
      return;
    }
  }
  file.createSync();
  file.writeAsStringSync(TEMPLATE);
  print(
      "Created new file '${fileName.endsWith(".boat") ? fileName : fileName + ".boat"}'");
}

String executeExpression(Task task) {
  final String command = task.tokens.first.commandName ?? "";

  if (task.tokens.first.type == TokenType.BlockEnd) {
    return executeEnd(task);
  }

  if (task.tokens.first.commandName == "SAIL ON") {
    return executeSail(task);
  }

  if (started)
    switch (command) {
      case "ADD":
        return executeAdd(task);
      case "ARRIVE AT":
        return executeArrive(task);
      case "BROADCAST":
        return executeBroadcast(task);
      case "CRASH INTO":
        return executeCrash(task);
      case "DIVIDE":
        return executeDivide(task);
      case "DROP":
        return executeDrop(task);
      case "LISTEN TO":
        return executeListen(task);
      case "LOOP":
        return executeLoop(task);
      case "MULTIPLY":
        return executeMultiply(task);
      case "REPACK":
        return executeRepack(task);
      case "REQUEST":
        return executeRequest(task);
      case "RETURN":
        return executeReturn(task);
      case "SET":
        return executeSet(task);
      case "SINK":
        return executeSink(task);
      case "SUBTRACT":
        return executeSubtract(task);
      case "WAIT":
        return executeWait(task);
      default:
        return error("Unknown command");
    }
  return error("'SAIL' must be the first command!");
}

// Syntax: ADD [BARREL] TO [BARREL]
String executeAdd(Task task) {
  if (task.tokens.length != 4 || task.tokens[2].keyword != "TO")
    error("Hey captain, we don't understand your orders!");

  double toAdd = 0;
  ArgumentHelper toAddArg = ArgumentHelper(task.tokens[1]);

  if (toAddArg.isBarrelSet) {
    toAdd = toAddArg.barrelValue;
  } else {
    error("We cannot add it!");
  }

  if (task.tokens.last.type != TokenType.VariableName) {
    error("Hey captain, we don't understand your orders!");
  }

  barrels[task.tokens.last.variableName ?? ""] =
      toAdd + barrels[task.tokens.last.variableName ?? ""]!;

  return barrels[task.tokens.last.variableName ?? ""].toString();
}

// Syntax: ARRIVE AT [PACKAGE]
String executeArrive(Task task) {
  if (task.tokens.length != 2) {
    return error("Hey captain, we don't understand your orders!!");
  }

  return exit(0);
}

// Syntax: BROADCAST [BARREL|PACKAGE]
String executeBroadcast(Task task) {
  if (task.tokens.length != 2) {
    return error("Hey captain, we don't understand your orders!");
  }

  String toPrint = "";
  ArgumentHelper toPrintArg = ArgumentHelper(task.tokens[1]);

  if (toPrintArg.isBarrelSet) {
    toPrint = toPrintArg.barrelValue.toString();
  } else {
    toPrint = toPrintArg.packageValue;
  }

  print(toPrint);
  return toPrint;
}

// Syntax: CRASH INTO [PACKAGE]
String executeCrash(Task task) {
  if (task.tokens.length != 2) {
    return error("Hey captain, we don't understand your orders!");
  }

  return exit(1);
}

// Syntax: DIVIDE [BARREL] BY [BARREL]
String executeDivide(Task task) {
  if (task.tokens.length != 4 || task.tokens[2].keyword != "BY") {
    return error("Hey captain, we don't understand your orders!");
  }

  double toDivide = 0;
  ArgumentHelper toDivideArg = ArgumentHelper(task.tokens.last);

  if (toDivideArg.isBarrelSet) {
    toDivide = toDivideArg.barrelValue;
  } else {
    error("We cannot divide it!");
  }

  if (task.tokens[1].type != TokenType.VariableName) {
    error("Hey captain, we don't understand your orders!");
  }

  if (toDivide == 0) {
    error("Hey captain, we cannot divide by zero!");
  }

  barrels[task.tokens[1].variableName ?? ""] =
      barrels[task.tokens[1].variableName ?? ""]! / toDivide;
  return barrels[task.tokens[1].variableName ?? ""].toString();
}

// Syntax: DROP [BARREL|PACKAGE]
String executeDrop(Task task) {
  if (task.tokens.length != 2) {
    return error("Hey captain, we don't understand your orders!");
  }

  if (packages.containsKey(task.tokens.last.variableName)) {
    packages.remove(task.tokens.last.variableName);
  }

  if (barrels.containsKey(task.tokens.last.variableName)) {
    barrels.remove(task.tokens.last.variableName);
  }

  return "";
}

// Syntax: END
String executeEnd(Task task) {
  if (task.tokens.length != 1) {
    return error("Hey captain, we don't understand your orders!!");
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

// Syntax: LISTEN TO [PACKAGE]
String executeListen(Task task) {
  if (task.tokens.length != 2) {
    return error("Hey captain, we don't understand your orders!");
  }

  if (!packages.containsKey(task.tokens.last.variableName)) {
    return error(
        "No matter how hard we try, we cannot find package ${task.tokens.last.variableName} in your cabin...");
  }

  String input = stdin.readLineSync() ?? "";

  packages[task.tokens.last.variableName ?? ""] = input;

  return "\"$input\"";
}

// Syntax: LOOP [BARREL] TIMES: ... END
String executeLoop(Task task) {
  if (task.tokens.length < 5 ||
      task.tokens[2].keyword == "TIMES" ||
      task.tokens.last.type == TokenType.BlockStart) {
    return error("Hey captain, we don't understand your orders!");
  }

  double iterations = 0;
  ArgumentHelper iterationsArg = ArgumentHelper(task.tokens[1]);
  if (iterationsArg.isBarrelSet) {
    iterations = iterationsArg.barrelValue;
  } else {
    error("Cannot loop!");
  }

  CodeBlockData toAdd = CodeBlockData(
    start: linePointer,
    type: CodeBlockType.Loop,
    iterationsLeft: iterations.ceil() - 1,
  );

  if (task.tokens.length == 5 && task.tokens[3].keyword == "AS") {
    createBarrel(task.tokens[4].variableName ?? "", 0);
    toAdd.iterationVar = task.tokens[4].variableName ?? "";
  }

  blocks.add(toAdd);
  return "";
}

// Syntax: IF {CONDITION}: ... END
/* String executeIf(Task task) {
  if (args.length < 4 || !args.last.endsWith(":")) {
    return error("Hey captain, we don't understand your orders!");
  }
  return "";
} */

// Syntax: MULTIPLY [BARREL] BY [BARREL]
String executeMultiply(Task task) {
  if (task.tokens.length != 4 || task.tokens[2].keyword != "BY") {
    return error("Hey captain, we don't understand your orders!");
  }

  double toMultiply = 0;
  ArgumentHelper toMultiplyArg = ArgumentHelper(task.tokens.last);

  if (toMultiplyArg.isBarrelSet) {
    toMultiply = toMultiplyArg.barrelValue;
  } else {
    error("Cannot multiply!");
  }

  if (task.tokens[1].type != TokenType.VariableName) {
    error("Hey captain, we don't understand your orders!");
  }

  barrels[task.tokens[1].variableName ?? ""] =
      barrels[task.tokens[1].variableName ?? ""]! / toMultiply;
  return barrels[task.tokens[1].variableName ?? ""].toString();
}

// Syntax: REPACK [BARREL|PACKAGE] TO (BARREL|PACKAGE)
String executeRepack(Task task) {
  if (task.tokens.length != 4 || task.tokens[2].keyword != "TO") {
    return error("Hey captain, we don't understand your orders!");
  }

  if (barrels.containsKey(task.tokens[1].variableName)) {
    if (task.tokens[3].variableType == "PACKAGE") {
      String value = barrels[task.tokens[1].variableName].toString();

      barrels.remove(task.tokens[1].variableName);
      createPackage(task.tokens[1].variableName ?? "", value);
      return '';
    }
    return "";
  }

  if (packages.containsKey(task.tokens[1].variableName)) {
    if (task.tokens[3].variableType == "BARREL") {
      double? value =
          double.tryParse(packages[task.tokens[1].variableName] ?? "");

      if (value == null) {
        error(
            "Hey, this package ${packages[task.tokens[1].variableName]} cannot be converted to barrel");
        return '';
      }

      packages.remove(task.tokens[1].variableName);
      createBarrel(task.tokens[1].variableName ?? "", value);
      return '';
    }
    return "";
  }

  error("Variable ${task.tokens[1].variableName} is not defined");
  return "";
}

// Syntax: REQUEST (BARREL|PACKAGE) [PACKAGE]
String executeRequest(Task task) {
  if (task.tokens.length != 3) {
    return error("Hey captain, we don't understand your orders!");
  }

  if (task.tokens[1].variableType == "BARREL") {
    createBarrel(task.tokens[2].variableName ?? "", 0);
    return "0";
  }

  if (task.tokens[1].variableType == "PACKAGE") {
    createPackage(task.tokens[2].variableName ?? "", "");
    return "\"\"";
  }

  error("Hey captain, we don't understand your orders!");
  return "";
}

// Syntax: RETURN [BARREL|PACKAGE]
String executeReturn(Task task) {
  if (task.tokens.length != 2) {
    return error("Hey captain, we don't understand your orders!");
  }

  if (packages.containsKey(task.tokens[1])) {
    packages.remove(task.tokens[1]);
  }

  if (barrels.containsKey(task.tokens[1])) {
    barrels.remove(task.tokens[1]);
  }

  return "";
}

// Syntax: SAIL ON [PACKAGE]
String executeSail(Task task) {
  if (task.tokens.length != 2) {
    return error("Hey captain, we don't understand your orders!");
  }
  started = true;
  return "";
}

// Syntax: SET [BARREL|PACKAGE] TO [BARREL|PACKAGE]
String executeSet(Task task) {
  if (task.tokens.length != 4 || task.tokens[2].keyword != "TO") {
    return error("Hey captain, we don't understand your orders!");
  }

  ArgumentHelper toSetArg = ArgumentHelper(task.tokens.last);

  if (barrels.containsKey(task.tokens[1].variableName)) {
    double toSet = 0;

    if (toSetArg.isBarrelSet) {
      toSet = toSetArg.barrelValue;
    } else {
      error("Cannot set it");
    }

    barrels[task.tokens[1].variableName ?? ""] = toSet;
    return toSet.toString();
  }

  if (packages.containsKey(task.tokens[1].variableName)) {
    String toSet = "";

    if (toSetArg.isPackageSet) {
      toSet = toSetArg.packageValue;
    } else {
      error("Cannot set it");
    }

    packages[task.tokens[1].variableName ?? ""] = toSet;
    return "\"$toSet\"";
  }

  error("Variable ${task.tokens[1].variableName} is not defined");
  return "";
}

// Syntax: SINK
String executeSink(Task task) {
  return exit(1);
}

// Syntax: SUBTRACT [BARREL] FROM [BARREL]
String executeSubtract(Task task) {
  if (task.tokens.length != 4 || task.tokens[2].keyword != "FROM") {
    error("Hey captain, we don't understand your orders!");
  }

  double toSubtract = task.tokens[1].barrelValue ??
      getBarrel(task.tokens[1].variableName ?? "");

  ArgumentHelper toSubtractArg = ArgumentHelper(task.tokens[1]);

  if (toSubtractArg.isBarrelSet) {
    toSubtract = toSubtractArg.barrelValue;
  } else {
    error("We cannot subtract it!");
  }

  barrels[task.tokens.last.variableName ?? ""] =
      barrels[task.tokens.last.variableName ?? ""]! - toSubtract;

  return barrels[task.tokens.last.variableName ?? ""].toString();
}

// Syntax: WAIT [BARREL] (in ms)
String executeWait(Task task) {
  if (task.tokens.length != 2) {
    return error("Hey captain, we don't understand your orders!");
  }

  double ms = 0;

  ArgumentHelper msArg = ArgumentHelper(task.tokens.last);

  if (msArg.isBarrelSet) {
    ms = msArg.barrelValue;
  } else {
    error("Cannot wait!");
  }

  ms = ms.roundToDouble();

  sleep(Duration(milliseconds: ms.toInt()));
  return "${ms}";
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

double getBarrel(String name) {
  if (barrels.containsKey(name)) {
    return barrels[name] ?? 0.0;
  }
  error("Variable '$name' does not exist or is not BARREL!");
  return 0.0;
}

String getPackage(String name) {
  if (packages.containsKey(name)) {
    return packages[name] ?? "";
  }
  error("Variable '$name' does not exist or is not PACKAGE!");
  return "";
}

/* bool evaluateExpression(Task task) {
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
} */

String error(String text) {
  print(text);
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
