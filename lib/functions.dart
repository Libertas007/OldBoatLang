import 'context.dart';
import "scheduler.dart";
import 'main.dart';
import 'variables.dart';
import 'lexer.dart';

class BoatFunction {
  List<Task> tasks = [];
  List<BoatFunctionArgumentWrapper> arguments = [];
  String name;

  BoatFunction(this.name, this.tasks, this.arguments);

  Variable run(List<Token> tokenArgs) {
    ExecutionContext ctx = ExecutionContext();

    if (tokenArgs.length != arguments.length)
      error("Invalid number of arguments");

    List<Variable> args = tokenArgs
        .map((e) => ArgumentHelper(e, globalContext).variable)
        .toList();

    if (arguments.length != 0) {
      List<bool> results = [];

      for (var i = 0; i < arguments.length; i++) {
        results.add(args[i].sameType(arguments[i].variable));
      }

      if (results.any((element) => element == false))
        error("Invalid arguments");
    }

    for (var i = 0; i < arguments.length; i++) {
      ctx.variablePool.createVariable(arguments[i].name, args[i]);
    }

    for (ctx.taskPointer = 0;
        ctx.taskPointer < tasks.length;
        ctx.taskPointer++) {
      final task = tasks[ctx.taskPointer];
      lineNum = task.lineNumber;

      if (task.tokens.length != 0) {
        executeExpression(task, ctx);
      }
    }

    return None();
  }
}

class BoatFunctionArgumentWrapper {
  String name;
  Variable variable = None();

  BoatFunctionArgumentWrapper(this.name, this.variable);
}

enum VariableType { Barrel, Package }
