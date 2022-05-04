import 'main.dart';
import 'functions.dart';

class VariablePool {
  Map<String, Variable> variables = {};
  Map<String, VariablePool> pools = {};
  List<BoatFunction> functions = [];

  void createVariable(String name, Variable variable) {
    if (name.contains(".")) {
      List<String> split = name.split(".");
      String first = split.removeAt(0);

      if (!pools.containsKey(first)) {
        pools.addAll({first: VariablePool()});
      }

      return pools[first]!.createVariable(split.join("."), variable);
    }

    if (variables.containsKey(name)) {
      error("Variable already exists");
    }

    variables.addEntries([MapEntry(name, variable)]);
  }

  Variable getVariable(String name,
      {VariablePool? fallback, String? fullName}) {
    if (name.contains(".")) {
      List<String> split = name.split(".");
      String first = split.removeAt(0);

      if (pools.containsKey(first)) {
        return pools[first]!.getVariable(split.join("."), fullName: name);
      }

      if (globalContext.variablePool.pools.containsKey(first)) {
        return globalContext.variablePool.pools[first]!
            .getVariable(split.join("."), fullName: name);
      }

      error("Namespace '$first' doesn't exist");
    }

    if (variables.containsKey(name)) {
      return variables[name] ?? None();
    }

    if (fallback != null) {
      return fallback.getVariable(name);
    }

    if (globalContext.variablePool.variables.containsKey(name)) {
      return globalContext.variablePool.getVariable(name);
    }

    error("Variable '$name' does not exist!");
    return None();
  }

  void setVariable(String name, Variable variable,
      {VariablePool? fallback, String? fullName}) {
    if (name.contains(".")) {
      List<String> split = name.split(".");
      String first = split.removeAt(0);

      if (pools.containsKey(first)) {
        return pools[first]!
            .setVariable(split.join("."), variable, fullName: name);
      }

      if (globalContext.variablePool.pools.containsKey(first)) {
        return globalContext.variablePool.pools[first]!
            .setVariable(split.join("."), variable, fullName: name);
      }

      error("Namespace '$first' doesn't exist");
    }

    if (variables.containsKey(name)) {
      variables[name] = variable;
      return;
    }

    if (fallback != null) {
      return fallback.setVariable(name, variable);
    }

    if (globalContext.variablePool.variables.containsKey(name)) {
      return globalContext.variablePool.setVariable(name, variable);
    }

    error("Variable '$name' does not exist!");
  }

  BoatFunction getFunction(String name, {VariablePool? fallback}) {
    if (functions.any((func) => func.name == name))
      return functions.firstWhere((func) => func.name == name);

    if (name.contains(".")) {
      List<String> split = name.split(".");
      String first = split.removeAt(0);

      if (pools.containsKey(first)) {
        return pools[first]!.getFunction(split.join("."));
      }

      if (globalContext.variablePool.pools.containsKey(first)) {
        return globalContext.variablePool.pools[first]!
            .getFunction(split.join("."));
      }

      error("Namespace '$first' doesn't exist");
    }

    if (fallback != null) return fallback.getFunction(name);

    if (globalContext.variablePool.functions.any((func) => func.name == name))
      return globalContext.variablePool.functions
          .firstWhere((func) => func.name == name);

    error("Invalid name");
    return BoatFunction("", [], []);
  }

  bool functionExists(String name) {
    if (name.contains(".")) {
      List<String> split = name.split(".");
      String first = split.removeAt(0);

      if (pools.containsKey(first)) {
        return pools[first]!.functionExists(split.join("."));
      }

      if (globalContext.variablePool.pools.containsKey(first)) {
        return globalContext.variablePool.pools[first]!
            .functionExists(split.join("."));
      }

      error("Namespace '$first' doesn't exist");
    }

    if (functions.any((element) => element.name == name)) return true;
    if (globalContext.variablePool.functions
        .any((element) => element.name == name)) return true;

    return false;
  }
}

class Variable {
  dynamic value;
  List<Variable> extendsTypes = [];

  bool sameType(Variable variable) {
    return this.runtimeType == variable.runtimeType;
  }
}

class Package extends Variable {
  covariant String value = "";

  Package(this.value);

  @override
  String toString() {
    return value;
  }
}

class Barrel extends Variable {
  covariant double value = 0;

  Barrel(this.value);

  @override
  String toString() {
    return value.toString();
  }
}

class Switch extends Variable {
  covariant bool value = false;

  Switch(this.value);

  @override
  String toString() {
    return value.toString();
  }
}

class None extends Variable {
  covariant String value = "__NONE__";

  @override
  String toString() {
    return "NONE";
  }
}
