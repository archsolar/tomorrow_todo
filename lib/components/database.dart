import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'stored_structs.dart';

/// Database control panel.
/// A little messy, but it's fine for this small app.
class Database {
  static late Isar isar;

  // Initialize database
  static Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    // Ensure the directory exists
    if (!await appDir.exists()) {
      await appDir.create();
    }

    String path = appDir.path;
    if (Platform.isLinux) {
      path = '${appDir.path}/tomorrow_todo';
      final customDir = Directory(path);
      // Ensure the directory exists
      if (!await customDir.exists()) {
        await customDir.create();
      }
    }
    // If the operating system is Windows, change the directory
    if (Platform.isWindows) {
      path = '${appDir.path}\\tomorrow_todo';
      final customDir = Directory(path);

      // Ensure the directory exists
      if (!await customDir.exists()) {
        await customDir.create();
      }
    }
    isar = await Isar.open(
      [PreferenceSchema, TaskSchema],
      directory: path,
    );
  }

  // Get all tasks of date
  static Future<List<Task>> getTasksByDate(DateTime date) {
    return isar.tasks.filter().dateEqualTo(date).findAll();
  }

  static Future<List<Task>> getAllTasks() async {
    return await isar.txn(() async {
      return isar.tasks.where().findAll();
    });
  }

  // Add a task
  static insertTask(String title) async {
    final newTask = Task()..title = title;
    await isar.writeTxn(() async {
      await isar.tasks.put(newTask);
    });
  }

  // Update a task
  // Toggle done
  static toggleDone(Task task) async {
    await isar.writeTxn(() async {
      task.done = !task.done;
      await isar.tasks.put(task);
    });
  }

  // Toggle recurring
  // toggleRecurring(Task task) async {
  //   await isar.writeTxn(() async {
  //     task.recurring = !task.recurring;
  //     await isar.tasks.put(task);
  //   });
  // }
  static changeTaskTitle(Task task, String newTitle) async {
    await isar.writeTxn(() async {
      task.title = newTitle;
      await isar.tasks.put(task);
    });
  }

  // Delete a task
  static deleteTask(Id taskId) async {
    await isar.writeTxn(() async {
      final success = await isar.tasks.delete(taskId);
      // Idea replace with onscreen alert.
      if (!success) {
        // Do nothing
        // throw Exception("Failed to delete task, please contact Developer");
      }
    });
  }

  // Either returns preference or null if it fails to fetch.
  static Future<Preference?> tryGetPreferences() async {
    final preferences = await isar.preferences.getAll([0]);
    if (preferences.isEmpty || preferences.first == null) {
      return null;
    }
    return preferences.first!;
  }

  // Get preference or create a new one.
  static Future<Preference> getPreferences() async {
    final preferences = await isar.preferences.getAll([0]);
    if (preferences.isEmpty || preferences.first == null) {
      return Preference();
    }
    return preferences.first!;
  }

  // Set darkmode
  static setDarkMode(bool darkMode) async {
    Preference pref = await getPreferences();
    await isar.writeTxn(() async {
      pref.darkMode = !pref.darkMode;
      await isar.preferences.put(pref);
    });
  }

  static updateFont(String font) async {
    Preference pref = await getPreferences();
    await isar.writeTxn(() async {
      pref.font = font;
      await isar.preferences.put(pref);
    });
  }

  static updateFontSize(double fontSize) async {
    Preference pref = await getPreferences();
    await isar.writeTxn(() async {
      pref.fontSize = fontSize;
      await isar.preferences.put(pref);
    });
  }
}
