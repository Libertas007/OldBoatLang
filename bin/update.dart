import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boatlang/main.dart' show version, homeDirectory;

void main(List<String> args) async {
  print("Checking for updates...");

  String res = (await http.get(Uri.parse(
          "https://api.github.com/repos/Libertas007/BoatLang/releases/latest")))
      .body;

  Map<String, dynamic> asMap = jsonDecode(res);

  if (asMap["tag_name"] == version) {
    print("Everything is all right, you're up-to-date!");
    return;
  }

  List<dynamic> assets = asMap["assets"];

  print("Found newer version '${asMap["tag_name"]}'");
  String downloadUrl = assets.firstWhere((asset) =>
      asset["name"] ==
      packageNames[Platform.operatingSystem])["browser_download_url"];

  if (!Directory(homeDirectory() + ".boat").existsSync()) {
    print("'.boat' directory doesn't exist, making new");
    Directory(homeDirectory() + Platform.pathSeparator + ".boat").createSync();
  }

  print(
      "Downloading new version to '${homeDirectory() + Platform.pathSeparator}.boat${Platform.pathSeparator}'");

  final newVersion = await http.get(Uri.parse(downloadUrl));

  final file = File(homeDirectory() +
      Platform.pathSeparator +
      ".boat" +
      Platform.pathSeparator +
      (Platform.isWindows ? "boat.exe" : "boat"));

  print("Extracting to '${file.path}'");

  file.writeAsBytesSync(newVersion.bodyBytes);

  print("Done!");
}

Map<String, String> packageNames = {
  "windows": "boat-windows.exe",
  "linux": "boat-linux",
  "macos": "boat-mac",
};
