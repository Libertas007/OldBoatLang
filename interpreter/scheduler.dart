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

      if (token.type == TokenType.ReturnValueBind) {
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

    while (token.type != TokenType.EndOfLine &&
        token.type != TokenType.EndOfFile) {
      if (token.type != TokenType.ReturnValueBind) subTokens.add(token);
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
