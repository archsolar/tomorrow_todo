import 'package:isar/isar.dart';

part 'stored_structs.g.dart';

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
  double fontSize = 14.0;
  String font = "Roboto";
}
