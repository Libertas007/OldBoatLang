import 'package:boatlang/main.dart';

void main(List<String> arguments) {
  try {
    boatMainEntryPoint(arguments);
  } catch (e, s) {
    print("There was some problem in Boat core, please report it to Libertas.");
    print(e);
  }
}
