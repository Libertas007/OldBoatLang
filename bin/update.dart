import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boatlang/main.dart' show version;

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

  String downloadUrl = assets
      .firstWhere(
          (asset) => asset["name"] == packageNames[Platform.operatingSystem])
      .toList()[0]["browser_download_url"];

  print(downloadUrl);
}

Map<String, String> packageNames = {
  "windows": "boat-windows.exe",
  "linux": "boat-linux",
  "macos": "boat-mac",
};
