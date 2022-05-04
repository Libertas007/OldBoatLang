import 'context.dart';
import 'lexer.dart';
import 'main.dart';
import 'variables.dart';

class Scheduler {
  List<Token> tokens;
  List<Task> tasks = [];
  Token token = Token(TokenType.BlockEnd, -1);
  int pos = -1;

  Scheduler(this.tokens) {
    nextToken();
    run();
  }

  void run() {
    List<Token> toMake = [];
    bool ignore = false;
    int lineNum = -1;

    while (token.type != TokenType.EndOfFile) {
      if (lineNum == -1) {
        lineNum = token.lineNum;
      }
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
        tasks.add(Task(toMake, lineNum));
        toMake = [];
        nextToken();
        continue;
      }
      if (!ignore) toMake.add(token);
      nextToken();
    }

    tasks.add(Task(toMake, lineNum));
  }

  void nextToken() {
    pos++;
    token = pos < tokens.length ? tokens[pos] : Token(TokenType.EndOfFile, -1);
  }

  Token makeSubtoken() {
    List<Token> subTokens = [];
    int lineNum = token.lineNum;
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

    return Token(TokenType.Task, lineNum, task: Task(subTokens, lineNum));
  }

  @override
  String toString() {
    return this.tasks.join("\n");
  }
}

class Task {
  List<Token> tokens;
  int lineNumber;

  Task(this.tokens, this.lineNumber);

  @override
  String toString() {
    return "{" + this.tokens.join(", ") + "}";
  }
}

class ArgumentHelper {
  ExecutionContext ctx;
  Variable variable = None();

  ArgumentHelper(Token token, this.ctx) {
    switch (token.type) {
      case TokenType.BarrelLiteral:
        variable = Barrel(token.barrelValue ?? 0);
        break;
      case TokenType.PackageLiteral:
        variable = Package(token.packageValue ?? "");
        break;
      case TokenType.Task:
        variable = executeExpression(token.task ?? Task([], -1), ctx);
        break;
      case TokenType.VariableName:
        resolveVariable(token);
        break;
      default:
        break;
    }
  }

  void resolveVariable(Token token) {
    if (ctx.variablePool.variables.containsKey(token.variableName)) {
      variable = ctx.variablePool.getVariable(token.variableName ?? "");
    } else {
      error("There's no '${token.variableName}' in your cabin!");
    }
  }

  @override
  String toString() {
    if (variable is Barrel) return "<BARREL:${variable.value}>";
    if (variable is Package)
      return "<PACKAGE:${variable.value}>";
    else
      return "<>";
  }
}
