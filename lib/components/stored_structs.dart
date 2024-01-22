import 'package:isar/isar.dart';

part 'stored_structs.g.dart';

const List<double> fontSizes = [23.0, 25.0, 28.0];
const List<String> fontNames = ['OpenSans', 'Default', 'Oswald'];

@collection
class Task {
  Id id = Isar.autoIncrement;
  String title = "";
  bool done = false;
  // bool recurring = false;
  DateTime date = DateTime.now().add(const Duration(days: 1));
  Task({this.title = ""});
}

@collection
class Preference {
  Id id = 0;
  bool darkMode = true;
  double fontSize = fontSizes[1];
  String font = fontNames[1];
  DateTime dayStartTime = DateTime.now();
}

/// Returns middle of the day tomorrow.
DateTime returnDate() {
  DateTime date = DateTime.now().add(const Duration(days: 1));
  // date = date.add(const Duration(hours: 12));
  // DateTime dateOnly = DateTime(date.year, date.month, date.day);

  return date;
}