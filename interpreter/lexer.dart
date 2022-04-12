import 'main.dart';
import 'scheduler.dart';

final String numbers = "0123456789";
final String letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
final String validInKeywords = "_";
const operators = ["==", ">=", "<=", "!=", "!", ">", "<"];
const keywords = ["TO", "BY", "FROM", "LOOP", "TIMES", "AS", "END", "IF"];
const commands = [
  "ADD",
  "ARRIVE AT",
  "BROADCAST",
  "CRASH INTO",
  "DIVIDE",
  "DROP",
  "LISTEN TO",
  "MULTIPLY",
  "REPACK",
  "REQUEST",
  "RETURN",
  "SAIL ON",
  "SET",
  "SINK",
  "SUBTRACT",
  "WAIT"
];
final variableTypes = ["PACKAGE", "BARREL"];
final blockKeywords = ["IF", "LOOP"];

class Token {
  TokenType type;
  String? packageValue;
  double? barrelValue;
  String? keyword;
  String? commandName;
  String? variableType;
  String? variableName;
  Task? task;
  OperatorType? operatorType;
  int lineNum;

  Token(this.type, this.lineNum,
      {this.packageValue,
      this.barrelValue,
      this.commandName,
      this.keyword,
      this.variableName,
      this.variableType,
      this.task,
      this.operatorType});

  @override
  String toString() {
    if (packageValue != null) return "($type:$packageValue)";
    if (barrelValue != null) return "($type:$barrelValue)";
    if (commandName != null) return "($type:$commandName)";
    if (keyword != null) return "($type:$keyword)";
    if (variableType != null) return "($type:$variableType)";
    if (variableName != null) return "($type:$variableName)";
    if (operatorType != null) return "($type:$operatorType)";
    if (type == TokenType.Task) return "($type:$task)";
    return "($type)";
  }
}

enum TokenType {
  BarrelLiteral,
  PackageLiteral,
  VariableName,
  CommandName,
  EndOfLine,
  EndOfFile,
  ReturnValueBindStart,
  ReturnValueBindEnd,
  Keyword,
  BlockStart,
  BlockEnd,
  VariableType,
  Task,
  Operator,
  Comment,
}

class Lexer {
  final String text;
  int charPointer = -1;
  String char = "";
  List<Token> tokens = [];
  bool stringConstruction = false;
  bool keywordConstruction = false;
  String constructedValue = "";
  int lineNumber = -1;

  Lexer(this.text) {
    nextChar();
    process();
  }

  void nextChar() {
    charPointer++;
    char = charPointer < text.length ? text[charPointer] : "";
  }

  void process() {
    bool comment = false;

    while (char != "") {
      if ([" ", "\t", "\r"].contains(char)) {
        nextChar();
        continue;
      }

      if (operators.any((element) => element.startsWith(char))) {
        makeOperator();
        nextChar();
        continue;
      }

      if (numbers.contains(char)) {
        makeNumber();
        continue;
      }

      if (letters.contains(char)) {
        makeKeyword();
        continue;
      }

      if (char == "\"") {
        makeString();
        nextChar();
        continue;
      }

      switch (char) {
        case "\n":
          lineNumber++;
          tokens.add(Token(TokenType.EndOfLine, lineNumber));
          break;
        case ":":
          tokens.add(Token(TokenType.BlockStart, lineNumber));
          break;
        case "(":
          tokens.add(Token(TokenType.ReturnValueBindStart, lineNumber));
          break;
        case ")":
          tokens.add(Token(TokenType.ReturnValueBindEnd, lineNumber));
          break;
        case "/":
          if (comment)
            tokens.add(Token(TokenType.Comment, lineNumber));
          else
            comment = true;
          break;
        default:
          error("We don't know what '$char' is!");
      }
      nextChar();
    }
    tokens.add(Token(TokenType.EndOfFile, lineNumber));
  }

  void makeNumber() {
    int dotCount = 0;
    String numStr = "";

    while ([...numbers.split(""), "."].contains(char) && char != "") {
      if (char == ".") {
        if (dotCount == 1) {
          error("Too many dots in Barrel!");
        }

        dotCount++;
      }
      numStr += char;
      nextChar();
    }

    tokens.add(Token(TokenType.BarrelLiteral, lineNumber,
        barrelValue: double.parse(numStr)));
  }

  void makeKeyword() {
    String keyword = "";

    while ((letters.contains(char) ||
            validInKeywords.contains(char) ||
            numbers.contains(char) ||
            char == " ") &&
        char != "") {
      if (char == " " &&
          !commands.any((element) => element.startsWith(keyword + " "))) break;
      keyword += char;
      nextChar();
    }

    if (keyword == "END")
      tokens.add(Token(TokenType.BlockEnd, lineNumber));
    else if (keywords.contains(keyword))
      tokens.add(Token(TokenType.Keyword, lineNumber, keyword: keyword));
    else if (commands.contains(keyword))
      tokens
          .add(Token(TokenType.CommandName, lineNumber, commandName: keyword));
    else if (variableTypes.contains(keyword))
      tokens.add(
          Token(TokenType.VariableType, lineNumber, variableType: keyword));
    else
      tokens.add(
          Token(TokenType.VariableName, lineNumber, variableName: keyword));
  }

  void makeString() {
    String string = "";
    bool escape = false;
    nextChar();

    while ((char != "\"" || escape) && char != "") {
      string += char;
      if (char == "\\") escape = true;
      nextChar();
    }

    if (string.endsWith("\"")) string = string.substring(0, string.length - 1);

    tokens
        .add(Token(TokenType.PackageLiteral, lineNumber, packageValue: string));
  }

  void makeOperator() {
    String op = char;
    OperatorType? type;

    if (charPointer + 1 != text.length &&
        operators.contains(op + text[charPointer + 1])) {
      nextChar();
      op += char;
    }

    switch (op) {
      case "==":
        type = OperatorType.Equals;
        break;
      case "!=":
        type = OperatorType.NotEquals;
        break;
      case "!":
        type = OperatorType.Not;
        break;
      case ">=":
        type = OperatorType.GraterOrEqual;
        break;
      case "<=":
        type = OperatorType.LessOrEqual;
        break;
      case ">":
        type = OperatorType.GraterThan;
        break;
      case "<":
        type = OperatorType.LessThan;
        break;
      default:
    }

    if (type != null)
      tokens.add(Token(TokenType.Operator, lineNumber, operatorType: type));
    else
      error("We don't know what '$op' is!");
  }
}

enum OperatorType {
  Not,
  Equals,
  NotEquals,
  LessThan,
  GraterThan,
  LessOrEqual,
  GraterOrEqual
}

void main(List<String> args) {
  Lexer lexer = Lexer("<> <= >= == != !");
  print(lexer.tokens);
}
