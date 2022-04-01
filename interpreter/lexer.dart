import 'main.dart';
import 'scheduler.dart';

final String numbers = "0123456789";
final String letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
final String validInKeywords = "_";
final keywords = ["TO", "BY", "FROM", "LOOP", "TIMES", "AS", "END"];
final commands = [
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

class Token {
  TokenType type;
  String? packageValue;
  double? barrelValue;
  int? nestLevel;
  String? keyword;
  String? commandName;
  String? variableType;
  String? variableName;
  Task? task;

  Token(TokenType this.type,
      {this.packageValue,
      this.barrelValue,
      this.nestLevel,
      this.commandName,
      this.keyword,
      this.variableName,
      this.variableType,
      this.task});

  @override
  String toString() {
    if (packageValue != null) return "($type:$packageValue)";
    if (barrelValue != null) return "($type:$barrelValue)";
    if (commandName != null) return "($type:$commandName)";
    if (keyword != null) return "($type:$keyword)";
    if (variableType != null) return "($type:$variableType)";
    if (variableName != null) return "($type:$variableName)";
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
          tokens.add(Token(TokenType.EndOfLine));
          break;
        case ":":
          tokens.add(Token(TokenType.BlockStart));
          break;
        case "(":
          tokens.add(Token(TokenType.ReturnValueBindStart));
          break;
        case ")":
          tokens.add(Token(TokenType.ReturnValueBindEnd));
          break;
        case "/":
          if (comment)
            tokens.add(Token(TokenType.Comment));
          else
            comment = true;
          break;
        default:
          error("Unknown symbol '$char'");
      }
      nextChar();
    }
    tokens.add(Token(TokenType.EndOfFile));
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

    tokens
        .add(Token(TokenType.BarrelLiteral, barrelValue: double.parse(numStr)));
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
      tokens.add(Token(TokenType.BlockEnd));
    else if (keywords.contains(keyword))
      tokens.add(Token(TokenType.Keyword, keyword: keyword));
    else if (commands.contains(keyword))
      tokens.add(Token(TokenType.CommandName, commandName: keyword));
    else if (variableTypes.contains(keyword))
      tokens.add(Token(TokenType.VariableType, variableType: keyword));
    else
      tokens.add(Token(TokenType.VariableName, variableName: keyword));
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

    tokens.add(Token(TokenType.PackageLiteral, packageValue: string));
  }
}
