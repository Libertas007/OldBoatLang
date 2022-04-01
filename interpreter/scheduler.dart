import 'lexer.dart';
import 'main.dart';

class Scheduler {
  List<Token> tokens;
  List<Task> tasks = [];
  Token token = Token(TokenType.BlockEnd);
  int pos = -1;

  Scheduler(this.tokens) {
    nextToken();
    run();
  }

  void run() {
    List<Token> toMake = [];
    bool ignore = false;

    while (token.type != TokenType.EndOfFile) {
      if (token.type == TokenType.Comment) {
        ignore = true;
        nextToken();
        continue;
      }

      if (token.type == TokenType.ReturnValueBindStart) {
        toMake.add(makeSubtoken());
        nextToken();
        continue;
      }

      if (token.type == TokenType.EndOfLine ||
          token.type == TokenType.EndOfFile) {
        ignore = false;
        if (toMake == []) {
          nextToken();
          continue;
        }
        tasks.add(Task(toMake));
        toMake = [];
        nextToken();
        continue;
      }
      if (!ignore) toMake.add(token);
      nextToken();
    }

    tasks.add(Task(toMake));
  }

  void nextToken() {
    pos++;
    token = pos < tokens.length ? tokens[pos] : Token(TokenType.EndOfFile);
  }

  Token makeSubtoken() {
    List<Token> subTokens = [];
    nextToken();

    while (token.type != TokenType.EndOfLine &&
        token.type != TokenType.EndOfFile &&
        token.type != TokenType.ReturnValueBindEnd) {
      if (token.type != TokenType.ReturnValueBindStart)
        subTokens.add(token);
      else
        subTokens.add(makeSubtoken());
      nextToken();
    }

    return Token(TokenType.Task, task: Task(subTokens));
  }

  @override
  String toString() {
    return this.tasks.join("\n");
  }
}

class Task {
  List<Token> tokens;

  Task(this.tokens);

  @override
  String toString() {
    return "{" + this.tokens.join(", ") + "}";
  }
}

class ArgumentHelper {
  String packageValue = "";
  double barrelValue = 0;
  bool isBarrelSet = false;
  bool isPackageSet = false;

  ArgumentHelper(Token token) {
    switch (token.type) {
      case TokenType.BarrelLiteral:
        barrelValue = token.barrelValue ?? 0;
        isBarrelSet = true;
        break;
      case TokenType.PackageLiteral:
        packageValue = token.packageValue ?? "";
        isPackageSet = true;
        break;
      case TokenType.Task:
        resolveTask(token.task ?? Task([]));
        break;
      case TokenType.VariableName:
        resolveVariable(token);
        break;
      default:
        break;
    }
  }

  void resolveTask(Task task) {
    String value = executeExpression(task);
    if (double.tryParse(value) == null) {
      packageValue = value;
      isPackageSet = true;
    } else {
      barrelValue = double.tryParse(value) ?? 0;
      isBarrelSet = true;
    }
  }

  void resolveVariable(Token token) {
    if (barrels.containsKey(token.variableName)) {
      barrelValue = barrels[token.variableName ?? ""] ?? 0;
      isBarrelSet = true;
    } else if (packages.containsKey(token.variableName)) {
      packageValue = packages[token.variableName ?? ""] ?? "";
      isPackageSet = true;
    } else {
      error("There's no '${token.variableName}' in your cabin!");
    }
  }

  @override
  String toString() {
    if (isBarrelSet) return "<BARREL:$barrelValue>";
    if (isPackageSet)
      return "<PACKAGE:$packageValue>";
    else
      return "<>";
  }
}
