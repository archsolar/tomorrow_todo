import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/components/stored_structs.dart';

late Preference globalPref;

class PreferenceNotifier extends Notifier<Preference> {
  @override
  Preference build() => globalPref;

  void toggleDarkMode() {
    state = Preference()..darkMode = !state.darkMode;
    Database.setDarkMode(state.darkMode);
  }

  void set(Preference newPreference) {
    state = newPreference;
  }

  void setDarkMode(bool value) {
    state = Preference()..darkMode = value;
  }

  Future<void> setFontSize(double value) async {
    if (fontSizes.contains(value)) {
      await Database.updateFontSize(value);
      await fetchDatabase();
    }
  }

  Future<void> fetchDatabase() async {
    state = await Database.getPreferences();
  }

  Future<void> setFont(String value) async {
    if (fontNames.contains(value)) {
      await Database.updateFont(value);
      await fetchDatabase();
    }
  }
}

final preferenceProvider =
    NotifierProvider<PreferenceNotifier, Preference>(PreferenceNotifier.new);

class Settings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Query whether darkmode is on
    var preference = ref.watch(preferenceProvider);
    double fontSize = preference.fontSize;
    String fontFamily = preference.font;

    if (!fontSizes.contains(fontSize)) {
      fontSize = fontSizes[1];
    }
    if (!fontNames.contains(fontFamily)) {
      fontFamily = fontNames[1];
    }
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0.0), // adjust the value as needed
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Dark mode'),
              trailing: Switch(
                value: preference.darkMode,
                onChanged: (value) {
                  ref.read(preferenceProvider.notifier).toggleDarkMode();
                },
              ),
            ),
            ListTile(
              title: const Text('Font size'),
              trailing: DropdownButton<double>(
                value: fontSize,
                items: <DropdownMenuItem<double>>[
                  DropdownMenuItem<double>(
                    value: fontSizes[0],
                    child: const Text('23'),
                  ),
                  DropdownMenuItem<double>(
                    value: fontSizes[1],
                    child: const Text('25 (default)'),
                  ),
                  DropdownMenuItem<double>(
                    value: fontSizes[2],
                    child: const Text('28'),
                  ),
                ],
                onChanged: (double? newValue) {
                  if (newValue != null) {
                    ref.read(preferenceProvider.notifier).setFontSize(newValue);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Font type'),
              trailing: DropdownButton<String>(
                value: fontFamily,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: fontNames[0],
                    child: const Text('Open Sans'),
                  ),
                  DropdownMenuItem<String>(
                    value: fontNames[1],
                    child: const Text('Default'),
                  ),
                  DropdownMenuItem<String>(
                    value: fontNames[2],
                    child: const Text('Oswald'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    ref.read(preferenceProvider.notifier).setFont(newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
