dart2native -o releases/CLI/betascript source/main.dart
dart2js -o releases/web/tojs.js source/tojs.dart
cd releases/web
cp -v *  ../../../bs/interpreter
