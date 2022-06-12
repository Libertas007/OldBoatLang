import 'package:boatlang/variables.dart';

class Registry {
  List<Variable> variableTypes = [];

  registerVariableType(RegistryType type, Variable value) {
    switch (type) {
      case RegistryType.VariableName:
        variableTypes.add(value);
        break;
      default:
    }
  }
}

enum RegistryType {
  VariableName,
}
