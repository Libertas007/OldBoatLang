import 'dart:io';

import 'package:boatlang/main.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    await Process.start(
      pathToBoatExecutable(),
      [],
      mode: ProcessStartMode.inheritStdio,
    );
    return;
  }

  if (args.isNotEmpty && args[0] == "update") {
    await Process.start(
      pathToBoatUpdater(),
      [],
      mode: ProcessStartMode.inheritStdio,
    );
  } else {
    await Process.start(
      pathToBoatExecutable(),
      args,
      mode: ProcessStartMode.inheritStdio,
    );
  }
}
