// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/components/stored_structs.dart';
import 'package:tomorrow_todo/settings.dart';
import 'providers.dart';
import 'package:intl/intl.dart';

var dateCode = 'dd-MM';

// Idea: check if there are user settings available else fall back to this
TextTheme getTextTheme() {
  return const TextTheme(
    bodyMedium: TextStyle(fontSize: 25.0),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.init();
  // Set riverpod globals, so they'll be lazy loaded later.
  await _setGlobalPref();
  tasks = await Database.getAllTasks();
  runApp(ProviderScope(
    child: MyApp(),
  ));
}

ThemeMode getThemeMode() {
  // Idea: check if there are user settings available else fall back to this
  return ThemeMode.system;
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var preference = ref.watch(preferenceProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: getTextTheme(),
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, textTheme: getTextTheme()),
      themeMode: (preference.darkMode ? ThemeMode.dark : ThemeMode.light),
      debugShowCheckedModeBanner: false,
      // Idea: replace
      home: HomePage(title: 'Tomorrow TODO'),
    );
  }
}

class HomePage extends ConsumerWidget {
  final String title;

  final bottomInput = TextEditingController();

  HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: const Text("Settings"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settings()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Container(
                color: Theme.of(context).colorScheme.inversePrimary,
                child: const Center(child: Text(
                    // Idea: replace with some kind of digital date?
                    "4 January 2024"))), // It either reads {today's date} or "Tomorrow"
            SizedBox(height: 100, width: 150, child: successTiles(10)),
            Expanded(
              child: TaskViewer(),
            ),
            // Add tasks for tomorrow.
            TextField(
              onSubmitted: (value) {
                ref.read(taskProvider.notifier).addTask(value);
                bottomInput.clear();
              },
              controller: bottomInput,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tomorrow\'s tasks',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget square() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          color: Colors.green,
          width: 25,
          height: 25,
        ),
      ),
    );
  }

  String getDay(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  String getDate(DateTime date) {
    return DateFormat(dateCode).format(date);
  }

  Widget successTiles(int days) {
    // DateTime tomorrow_date = DateTime.now().add(const Duration(days: 1));
    DateTime firstIndex = DateTime.now().subtract(Duration(days: days - 1));

    return ListView.builder(
      itemCount: days + 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final DateTime baseDate = firstIndex;
        int remaining = days - index;
        String day;
        if (remaining == 0) {
          day = "Tomorrow";
        } else if (remaining <= 6) {
          day = getDay(baseDate.add(Duration(days: index)));
        } else {
          day = getDate(baseDate.add(Duration(days: index)));
        }
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 30,
            padding: const EdgeInsets.all(0),
            child: Stack(
              children: [
                Row(
                  children: [
                    Center(
                        child: Text(day,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .apply())),
                  ],
                ),
                Center(child: square()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TaskViewer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    return ListView(
      children: tasks.map((Task task) {
        return TaskEntry(
          task: task,
        );
      }).toList(),
    );
  }
}

class TaskEntry extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();
  final Task task;
  TaskEntry({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _controller.text = task.title;

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Edit Task'),
            content: TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Task title'),
            ),
            actions: [
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  ref
                      .read(taskProvider.notifier)
                      .editTaskTitle(task, _controller.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
          right: 8.0,
          bottom: 0.0, // No padding at the bottom
        ),
        child: Container(
          color: task.done ? Colors.green : Colors.red,
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Checkbox(
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith(getColor),
                value: task.done,
                onChanged: (bool? value) {
                  ref.read(taskProvider.notifier).toggleDone(task);
                },
              ),
              Expanded(child: Text(task.title)),
              IconButton(
                onPressed: () {
                  // Show a popup or perform some action before deleting the task
                  // You can use showDialog to create a confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Task'),
                        content:
                            Text('Are you sure you want to delete this task?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Delete the task here
                              ref.read(taskProvider.notifier).removeTask(task.id);
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _setGlobalPref() async {
  var pref = await Database.tryGetPreferences();
  if (pref == null) {
    // Fetch and use phone theme if preferences not available
    _setGlobalPrefBasedOnPlatform();
  } else {
    globalPref = pref;
  }
}

// Function to set globalPref based on platform theme
void _setGlobalPrefBasedOnPlatform() {
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
  globalPref = Preference()..darkMode = brightness == Brightness.dark;
}
