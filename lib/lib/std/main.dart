import 'package:boatlang/registry.dart';
import 'package:boatlang/variables.dart';
import 'package:boatlang/main.dart';

void execute() {
  registry.registerVariableType(RegistryType.VariableName, Barrel(0));
  registry.registerVariableType(RegistryType.VariableName, Package(""));
  registry.registerVariableType(RegistryType.VariableName, None());
  registry.registerVariableType(RegistryType.VariableName, Switch(false));
}
