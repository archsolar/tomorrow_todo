// ignore_for_file: file_names

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';

import 'components/stored_structs.dart';
late Preference globalPref;
class PreferenceNotifier extends Notifier<Preference> {
  @override
  Preference build() => globalPref;

  void toggleDarkMode() {
    state = Preference()..darkMode = !state.darkMode;
    Database.setDarkMode(state.darkMode);
  }
  void set(Preference newPreference) {
    state=newPreference;
  }
  void setDarkMode(bool value) {
    state = Preference()..darkMode = value;
  }
}

final preferenceProvider =
    NotifierProvider<PreferenceNotifier, Preference>(PreferenceNotifier.new);
