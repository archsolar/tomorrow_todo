// ignore_for_file: file_names

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';

import 'components/stored_structs.dart';

late Preference globalPref;
late Future<List<Task>> tasks;

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
}
class TaskNotifier extends Notifier<Future<List<Task>>> {
  @override
  Future<List<Task>> build() => tasks;

  Future<void> addTask(String title) async {
    final newTask = Task()..title = title;
    await Database.addTask(newTask);
    state = Database.getAllTasks();
  }

  Future<void> removeTask(int taskId) async {
    await Database.deleteTask(taskId);
    state = Database.getAllTasks();
  }

  Future<void> editTaskTitle(Task task, String newTitle) async {
    await Database.changeTaskTitle(task, newTitle);
    state = Database.getAllTasks();
  }

  Future<void> toggleDone(Task task) async {
    await Database.toggleDone(task);
    state = Database.getAllTasks();

  }
}

final preferenceProvider =
    NotifierProvider<PreferenceNotifier, Preference>(PreferenceNotifier.new);
final taskProvider =
    NotifierProvider<TaskNotifier, Future<List<Task>>>(TaskNotifier.new);



// Alternative
// // Idea option 1 this has awaits, option 2 this is an async with future,so awaits can be handled in the ui.
// class TaskNotifier extends Notifier<Future<List<Task>>> {
//   @override
//   Future<List<Task>> build() => tasks;

//   Future<void> addTask(String title) async {
//     final newTask = Task()..title = title;
//     await Database.addTask(newTask);
//     state = Database.getAllTasks();
//   }

//   Future<void> removeTask(int taskId) async {
//     await Database.deleteTask(taskId);
//     state = Database.getAllTasks();
//   }

//   Future<void> editTaskTitle(Task task, String newTitle) async {
//     await Database.changeTaskTitle(task, newTitle);
//     state = Database.getAllTasks();
//   }

//   Future<void> toggleDone(Task task) async {
//     await Database.toggleDone(task);
//     state = Database.getAllTasks();

//   }
// }

// final preferenceProvider =
//     NotifierProvider<PreferenceNotifier, Preference>(PreferenceNotifier.new);
// final taskProvider =
//     NotifierProvider<TaskNotifier, Future<List<Task>>>(TaskNotifier.new);
