// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/components/stored_structs.dart';
import 'package:tomorrow_todo/settings.dart';
import 'darkModeProvider.dart';
import 'package:intl/intl.dart';

var dateCode = 'dd-MM';

// Idea: check if there are user settings available else fall back to this
TextTheme getTextTheme() {
  return const TextTheme(
    bodyMedium: TextStyle(fontSize: 25.0),
  );
}

//TODO I want this to view newly added tasks somehow. Not sure how to do that.
final taskProvider = FutureProvider<List<Task>>((ref) async {
  return await Database.getAllTasks();
});
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.init();
  // await Database.insertTask("Test task");
  // Set riverpod globals, so they'll be lazy loaded later.
  await _setGlobalPref();

  runApp(const ProviderScope(child: MyApp()));
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
            const Expanded(
              child: TaskViewer(),
            ),
            // Add tasks for tomorrow.
            TextField(
              onSubmitted: (value) {
                Database.insertTask(value);
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
    DateTime firstIndex = DateTime.now().subtract(Duration(days: days-1));

    return ListView.builder(
      itemCount: days+1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final DateTime baseDate = firstIndex;
        int remaining = days-index;
        String day;
        if (remaining == 0) {
          day = "Tomorrow";
        } else if(remaining <= 6) {
          day = getDay(baseDate.add(Duration(days: index)));
        }
          else {
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

class TaskViewer extends StatefulWidget {
  const TaskViewer({super.key});

  @override
  TaskViewerState createState() => TaskViewerState();
}

class TaskViewerState extends State<TaskViewer> {
  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Database.getAllTasks();

    return FutureBuilder<List<Task>>(
      future: tasks,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return const Text("Wait for tomorrow/Something went wrong :)");
        } else {
          return ListView(
            children: snapshot.data!.map((Task task) {
              return TaskEntry(
                task: task,
                onUpdate: updateState,
              );
            }).toList(),
          );
        }
      },
    );
  }
}

class TaskEntry extends StatefulWidget {
  final Task task;
  final Function onUpdate;

  const TaskEntry({super.key, required this.task, required this.onUpdate});

  @override
  State<TaskEntry> createState() => _TaskEntryState();
}

class _TaskEntryState extends State<TaskEntry> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.task.title;
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Text('Save'),
                onPressed: () {
                  setState(() {
                    Database.changeTaskTitle(widget.task, _controller.text);
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  Database.deleteTask(widget.task.id).then((value) {
                    widget.onUpdate();
                  });
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
          color: widget.task.done ? Colors.green : Colors.red,
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Checkbox(
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith(getColor),
                value: widget.task.done,
                onChanged: (bool? value) {
                  setState(() {
                    Database.toggleDone(widget.task);
                  });
                },
              ),
              Expanded(child: Text(widget.task.title)),
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
