// ignore_for_file: file_names

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'components/stored_structs.dart';

class PreferenceNotifier extends Notifier<Preference> {
  @override
  Preference build() => Preference();

  void toggleDarkMode() {
    state = Preference()..darkMode = !state.darkMode;
  }

  void setDarkMode(bool value) {
    state = Preference()..darkMode = value;
  }

  // void set(Preference newState) {
  //   state = newState;
  // }
}

final preferenceProvider =
    NotifierProvider<PreferenceNotifier, Preference>(PreferenceNotifier.new);
