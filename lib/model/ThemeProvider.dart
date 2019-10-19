import 'package:flutter/material.dart';
import 'package:hasskit_2/helper/Logger.dart';

ThemeProvider pTheme;

class ThemeProvider with ChangeNotifier {
  int themeIndex = 3;
  List<ThemeData> themesData = [
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.grey,
    ),
    ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.grey,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.red,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.amber,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.teal,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.cyan,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
    ),
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.purple,
    ),
  ];

  get currentTheme {
    return themesData[themeIndex];
  }

  themeChange() {
    themeIndex = themeIndex + 1;
    if (themeIndex >= themesData.length) {
      themeIndex = 0;
    }
    log.d("themeIndex $themeIndex");
    notifyListeners();
  }
}
