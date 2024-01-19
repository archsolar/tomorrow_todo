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
  void setFontSize(double value) {
    state = Preference()..fontSize = value;
  }
  // void setFont() {

  // }
}

final preferenceProvider =
    NotifierProvider<PreferenceNotifier, Preference>(PreferenceNotifier.new);
const List<double> fontSizes = [23.0, 25.0, 28.0];
class Settings extends ConsumerWidget {
  String _fontFamily = 'Roboto';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Query whether darkmode is on
    var preference = ref.watch(preferenceProvider);
    double fontSize = preference.fontSize;
    if (!fontSizes.contains(fontSize)) {
      fontSize = 25.0;
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
                value: _fontFamily,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'Roboto',
                    child: Text('Roboto'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Arial',
                    child: Text('Arial'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Courier',
                    child: Text('Courier'),
                  ),
                ],
                onChanged: (String? newValue) {
                  // setState(() {
                  //   _fontFamily = newValue!;
                  // });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
