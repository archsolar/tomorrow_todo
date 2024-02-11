// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:todo_game/components/database.dart';
import 'package:todo_game/components/stored_structs.dart';
import 'package:todo_game/pages/settings.dart';

TextTheme getTextTheme(double fontSize, String fontFamily) {
  if (fontFamily == fontNames[1]) {
    return TextTheme(
      bodyMedium: TextStyle(fontSize: fontSize),
    );
  }
  return TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily),
    displayMedium: TextStyle(fontFamily: fontFamily),
    displaySmall: TextStyle(fontFamily: fontFamily),
    headlineLarge: TextStyle(fontFamily: fontFamily),
    headlineMedium: TextStyle(fontFamily: fontFamily),
    headlineSmall: TextStyle(fontFamily: fontFamily),
    titleLarge: TextStyle(fontFamily: fontFamily),
    titleMedium: TextStyle(fontFamily: fontFamily),
    titleSmall: TextStyle(fontFamily: fontFamily),
    bodyLarge: TextStyle(fontFamily: fontFamily),
    bodyMedium: TextStyle(fontSize: fontSize, fontFamily: fontFamily),
    bodySmall: TextStyle(fontFamily: fontFamily),
    labelLarge: TextStyle(fontFamily: fontFamily),
    labelMedium: TextStyle(fontFamily: fontFamily),
    labelSmall: TextStyle(fontFamily: fontFamily),
  );
}

Future<void> setGlobalPref() async {
  var pref = await Database.tryGetPreferences();
  if (pref == null) {
    // Fetch and use phone theme if preferences not available
    setGlobalPrefBasedOnPlatform();
  } else {
    globalPref = pref;
  }
}

/// Function to set globalPref based on platform theme
/// For now dark mode is true by default.
void setGlobalPrefBasedOnPlatform() {
  // var brightness =
  //     SchedulerBinding.instance.platformDispatcher.platformBrightness;
  // globalPref = Preference()..darkMode = brightness == Brightness.dark;
  globalPref = Preference()..darkMode = true;
}
