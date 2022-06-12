import 'context.dart';
import "scheduler.dart";
import 'main.dart';
import 'variables.dart';
import 'lexer.dart';

class BoatFunction {
  List<Task> tasks = [];
  List<BoatFunctionArgumentWrapper> arguments = [];
  String name;
  Variable Function(List<Variable> arguments, ExecutionContext ctx)? _function;

  BoatFunction(this.name, this.tasks, this.arguments);
  BoatFunction.native(
      this.name,
      this.arguments,
      Variable Function(List<Variable> arguments, ExecutionContext ctx)
          this._function);

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

    if (_function != null) {
      return _function!(arguments.map((e) => e.variable).toList(), ctx);
    }

    for (ctx.taskPointer = 0;
        ctx.taskPointer < tasks.length;
        ctx.taskPointer++) {
      final task = tasks[ctx.taskPointer];
      lineNum = task.lineNumber;

      if (task.tokens.isNotEmpty) {
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
