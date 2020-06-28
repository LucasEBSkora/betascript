import 'dart:io';

void main() {
  print(Process.runSync('dart2native', ["-o ../releases/CLI/betascript", "main.dart"] , workingDirectory: "../").stdout);
  print(Process.runSync('dart2js', ["-oreleases/web/out.js", "source/tojs.dart"], workingDirectory: "../../").stdout);
}